---
title: 'DuckDBとCodeMirrorを使って青空文庫のデータを検索する'
author: r74tech
categories:
  - web
tags:
  - duckdb
math: false
mermaid: false
slug: 2024-12-19-aozora-duckdb
image:
  path: /assets/img/og/2024-12-19-aozora-duckdb.png
  show: false
---

# DuckDBとCodeMirrorを使って青空文庫のデータを検索する

[脆弱エンジニアの Advent Calendar 2024](https://qiita.com/advent-calendar/2024/full-weak-engineer) 19日目の記事です。

## 謝辞

本プロジェクトは[@voluntas](https://github.com/voluntas)さんの[duckdb-wasm-parquet](https://github.com/voluntas/duckdb-wasm-parquet)を参考にさせていただきました。この場を借りて感謝申し上げます。

## TL;DR
[青空文庫データ分析ツール](https://r74tech.github.io/aozora-duckdb/)を作成しました。DuckDBとCodeMirrorを使って、青空文庫のデータをブラウザ上で検索・分析できるようにしました。

## はじめに

青空文庫には多くの無料で読める文学作品が収録されていますが、大量のデータから特定の作品や著者を効率的に検索したり、データを分析したりするのは容易ではありません。この記事では、ブラウザ上で動作する軽量データベースエンジン **DuckDB** とインタラクティブなコードエディタ **CodeMirror** を組み合わせて、青空文庫のデータを快適に検索・分析できるツールを構築する方法を解説します。

## DuckDBとは

[DuckDB](https://duckdb.org/)は、分析用に設計された組み込み型SQLデータベースエンジンです。PostgreSQLに似た文法を持ちながら、より分析処理に特化した機能を提供します。

### 主な特徴

1. **アナリティクス指向のアーキテクチャ**
   - 列指向ストレージエンジンによる高速な分析処理  
     列指向ストレージエンジンは、列ごとにデータを格納することで、必要な列のみを効率的に読み取ることができます。これにより、大規模なデータセットに対してもメモリ使用量を抑えつつ、高速に分析処理を行えます[^1]。
   - ベクトル化実行エンジンによる効率的なクエリ処理  
     ベクトル化実行エンジンは、データをチャンク単位で処理し、CPUキャッシュの効率を最大化します[^2]。
   - OLAP（Online Analytical Processing）ワークロードに最適化  
     OLAP向けのクエリ処理は、大量のデータの集計や分析を短時間で行うことを目指しています。

2. **トランザクションサポート**
   - ACID準拠のトランザクション  
     データベースがAtomicity, Consistency, Isolation, Durabilityを満たすことで、信頼性の高いデータ処理を保証します[^3]。
   - スナップショットアイソレーション  
     複数のトランザクションが並行して実行されても、一貫した結果を提供します[^4]。

### WebAssembly版の特徴

DuckDB-WASMは、ブラウザ上で動作するDuckDBの実装です。

- **完全なクライアントサイド処理**
  - サーバーレスでの分析が可能
  - ネットワーク遅延なしでのクエリ実行
  - プライバシー保護（データがローカルで処理される）[^5]

- **ブラウザストレージとの統合**
  - File System Access API対応[^6]
  - IndexedDBを使用したデータの永続化
  - OPFS（Origin Private File System）サポート[^7]


### Parquet形式との連携

DuckDBは **Apache Parquet** 形式との親和性が高く、以下の利点があります。

- 列指向フォーマットによる効率的なデータ格納
- 高い圧縮率によるストレージ効率の向上
- スキーマ情報の保持による型安全性
- 必要な列のみを読み込むことによる高速化

## CodeMirrorについて

[CodeMirror](https://codemirror.net/)は、プログラマブルなテキストエディタを実現するためのTypeScriptライブラリです。バージョン6から完全に再設計され、より高度な機能と柔軟性を提供しています。

### 主要機能

1. **最新のエディタ機能**
   - ユニコード対応
   - 双方向テキストのサポート
   - モバイルデバイスへの対応
   - カスタマイズ可能なキーバインディング

2. **プログラミング言語サポート**
   - 200以上の言語に対応
   - SQLの高度な構文ハイライト
   - リアルタイムの構文エラー検出
   - オートコンプリート機能

3. **拡張システム**
   - State Field API による状態管理
   - Compartments による拡張の分離
   - View Plugins によるUI拡張
   - Facet による設定の管理


### SQLエディタとしての利用

CodeMirrorをSQLエディタとして活用する際の主な設定項目。

```typescript
const editor = new EditorView({
    state: EditorState.create({
        doc: DEFAULT_SQL,
        extensions: [
            sql(),                    // SQLサポート
            basicSetup,               // 基本機能セット
            EditorView.lineWrapping,  // 行折り返し
            EditorState.readOnly.of(false), // 編集可能設定
            // SQLに特化したスタイル設定
            EditorView.theme({
                "&": {
                    height: "400px",
                    maxWidth: "100%"
                },
                ".cm-content": {
                    fontFamily: "monospace"
                }
            })
        ]
    })
});
```

### パフォーマンス特性

- **仮想DOM不使用**: 直接DOMを操作し高速なレンダリング
- **インクリメンタルパース**: 変更された部分のみを再解析
- **レイジーローディング**: 必要な機能のみを読み込み

## データ処理の詳細

### 青空文庫のテキスト形式

青空文庫のテキストには、以下のような特殊な形式が含まれています。

1. **ルビ（読み仮名）**
   - 例: `零時半《れいじはん》`
   - 例: `桜《さくら》の花`

2. **注記**
   - 例: `［＃ここから２字下げ］`
   - 例: `［＃「」は縦線付きの七重鉤括弧、第３段］`

### テキストクリーニング

#### ルビの処理

```python
def remove_ruby(text: str) -> str:
    """ルビを削除する関数"""
    # 漢字《よみがな》形式のルビを削除
    text = re.sub(r'([^《]*)《[^》]*》', r'\1', text)
    return text
```

この関数は以下のように動作します。
- `零時半《れいじはん》` → `零時半`
- `桜《さくら》の花` → `桜の花`

#### 完全なテキストクリーニング

```python
def clean_text(text: Optional[str]) -> Optional[str]:
    """テキストをクリーンアップする関数"""
    if text is None:
        return None
    
    # Unicode正規化（NFKC）
    text = unicodedata.normalize('NFKC', text)
    
    # ルビの削除
    text = remove_ruby(text)
    
    # 制御文字の除去（改行は保持）
    text = ''.join(char for char in text 
                  if char == '\n' or unicodedata.category(char)[0] != 'C')
    
    # 注記の削除
    text = re.sub(r'［＃[^］]*］', '', text)
    
    # 改行の正規化
    text = text.replace('\r\n', '\n').replace('\r', '\n')
    
    # 連続する空白や改行を1つに
    text = re.sub(r'\n\s*\n', '\n\n', text)
    text = re.sub(r'[ \t]+', ' ', text)
    
    return text.strip()
```

### Parquetファイルへの変換と分割

データ処理の最終段階として、クリーニングしたテキストをParquet形式に変換し、扱いやすいサイズに分割します。

```python
def split_parquet_file(input_file: str, output_dir: str = "splits"):
    """Parquetファイルを60MB単位で分割する"""
    con = duckdb.connect()
    
    # 総行数の取得
    total_rows = con.execute(
        "SELECT COUNT(*) FROM read_parquet(?)", 
        [input_file]
    ).fetchone()[0]
    
    # 6分割（各60MB程度）
    rows_per_chunk = total_rows // 6
    
    for i in range(6):
        output_file = f'aozora_combined_part{i:02d}.parquet'
        
        # 分割してエクスポート
        con.execute(f"""
            COPY (
                SELECT *
                FROM read_parquet('{input_file}')
                LIMIT {rows_per_chunk}
                OFFSET {i * rows_per_chunk}
            ) TO '{output_file}' 
            (FORMAT 'parquet', COMPRESSION 'zstd')
        """)
```

## アプリケーションの実装

このアプリケーションは、青空文庫のデータをParquetファイルから読み込み、DuckDB WASTを使用してブラウザ上でSQLクエリを実行できるようにします。

### DuckDBの初期化とデータロード

```typescript
// DuckDBの初期化
const worker = new duckdb_worker()
const logger = new duckdb.ConsoleLogger()
const db = new duckdb.AsyncDuckDB(logger, worker)
await db.instantiate(duckdb_wasm)

async function loadParquetParts(db) {
  const baseUrl = import.meta.env.BASE_URL || '/';
  const totalParts = 6;
  
  try {
    const conn = await db.connect();
    
    for (let i = 0; i < totalParts; i++) {
      // OPFSからバッファを取得を試みる
      let buffer = await getBufferFromOPFS(i);
      
      // キャッシュにない場合はダウンロード
      if (!buffer) {
        const partUrl = new URL(
          `${FILE_NAME_PREFIX}${i.toString().padStart(2, '0')}.parquet`,
          window.location.origin + baseUrl
        ).href;
        
        // ダウンロードとプログレス表示の処理
        const response = await fetch(partUrl);
        // ... ストリーム処理とプログレス更新 ...
        
        // OPFSへの保存
        await saveStreamToOPFS(stream, i);
        buffer = await getBufferFromOPFS(i);
      }
      
      // DuckDBへの登録
      await db.registerFileBuffer(`part${i}.parquet`, new Uint8Array(buffer));
      
      // テーブルの作成または追加
      if (i === 0) {
        await conn.query(`
          CREATE TABLE aozora_combined AS 
          SELECT * FROM read_parquet('part0.parquet');
        `);
      } else {
        await conn.query(`
          INSERT INTO aozora_combined 
          SELECT * FROM read_parquet('part${i}.parquet');
        `);
      }
    }
  } catch (error) {
    throw error;
  }
}
```

### 検索機能の実装

```typescript
// 基本検索機能
searchInput?.addEventListener('input', async () => {
  const searchTerm = searchInput.value.trim()
  if (!searchTerm) {
    const resultElement = document.getElementById('result')
    if (resultElement) resultElement.innerHTML = ''
    return
  }

  const conn = await db.connect()
  try {
    const result = await conn.query(`
      SELECT 作品名, 姓 || ' ' || 名 as 著者名, 公開日
      FROM aozora_combined
      WHERE 作品名 LIKE '%${searchTerm}%'
         OR 姓 LIKE '%${searchTerm}%'
         OR 名 LIKE '%${searchTerm}%'
      LIMIT 100;
    `)
    displayResults(result)
  } finally {
    await conn.close()
  }
})

// 著者統計
document.getElementById('author-stats')?.addEventListener('click', async () => {
  const conn = await db.connect()
  try {
    const result = await conn.query(`
      SELECT 
        姓 || ' ' || 名 as 著者名,
        COUNT(*) as 作品数,
        MIN(公開日) as 最初の公開日,
        MAX(公開日) as 最新の公開日
      FROM aozora_combined
      GROUP BY 姓, 名
      ORDER BY 作品数 DESC
      LIMIT 20;
    `)
    displayResults(result)
  } finally {
    await conn.close()
  }
})
```

## まとめと今後の展望

本プロジェクトでは、DuckDBとCodeMirrorを組み合わせることで、以下を実現しました。

- ブラウザ上での高速なテキストデータ検索
- インタラクティブなSQLクエリ実行環境
- サーバーレスでの大規模テキストデータ分析


## ライセンス

本プロジェクトはApache License 2.0の下で公開されています。

---

[^1]: DuckDB Documentation: [File Formats](https://duckdb.org/docs/guides/performance/file_formats#reasons-for-querying-parquet-files)
[^2]: DuckDB Documentation: [Execution Format](https://duckdb.org/docs/internals/vector#data-flow)
[^3]: ACID Compliance: [Changing Data with Confidence and ACID](https://duckdb.org/2024/09/25/changing-data-with-confidence-and-acid.html)
[^4]: [Snapshot Isolation](https://jepsen.io/consistency/models/snapshot-isolation)
[^5]: DuckDB WASM: [Running in the Browser](https://duckdb.org/docs/api/wasm/overview/)
[^6]: File System Access API: [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/API/File_System_Access_API)
[^7]: OPFS Support: [OPFS API Overview](https://web.dev/file-system-access/)
