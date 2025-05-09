---
title: 'CRTP (Certified Red Team Professional) Certification Experience'
author: r74tech
categories:
  - Experience
tags:
  - CRTP
  - Security
  - Offensive Security
  - Red Team
math: false
mermaid: false
slug: 2025-03-23-crtp-certification-experience
image:
  path: /assets/img/og/2025-03-23-crtp-certification-experience.png
  show: false
---

## はじめに

CRTP（Certified Red Team Professional）試験を最近受験し、合格することができました。この体験記では、試験準備から実技、レポート作成までの実際の経験と、これから受験する方へのアドバイスを詳しく共有します。

## 試験の背景

CRTPはAltered Securityが提供するハンズオン形式の資格試験です。費用は$249で、これには30日間のラボアクセスと1回の試験機会が含まれています。再受験が必要な場合は$99です。試験は24時間の実技試験と、その後24時間のレポート作成から構成されています。Nikhil Mittal氏の教材は非常に分かりやすく、Active Directoryの基礎から高度な攻撃手法まで網羅的に解説されています。

## 準備のための詳細なアプローチ

### 学習方法の最適化

1. **体系的なノート作成**: 各攻撃テクニックについて以下の情報を整理しました。
   - 攻撃の目的と達成できること
   - 脆弱性の本質と攻撃が可能な理由
   - 攻撃の具体的な手順と必要なツール
   - コマンド例と成功/失敗時のメッセージパターン

2. **マニュアルの最終確認**: 試験直前に<span style="color: #404040; text-decoration: line-through;">（試験当日の深夜0時から4時まで）</span>PowerShellのマニュアルを1周し、どのセクションにどの情報があるかを再確認しました。これは試験中に非常に役立ちました。

3. **チートシートの作成**: モジュールのインポートからフォレスト間の権限昇格まで、すべての重要なコマンドを記録したチートシートを作成しました。これにより試験中にコマンドをコピー＆ペーストするだけで素早く操作できました。

### 言語の準備

英語に不安がある場合は、ラボを開始する前に重要な部分を翻訳しておくことをお勧めします。特に技術用語や手順の説明は事前に理解しておくと、試験中のストレスが大幅に軽減されます。

## 試験環境のセットアップと管理

### 効率的な環境構築

試験開始後の1時間で、最初にボリュームマウントを設定し、必要なツールをすべてアップロードしておくことが重要です。その後はブラウザからRDPで接続すれば、スムーズに作業を進めることができます。

### トラブルシューティング

ラボ環境が反応しなくなった場合の対処法。
1. パニックにならず、ダッシュボードは開いたまま15分ほど待ちましょう
2. 自動的に再起動しない場合は、再起動ボタンを押してみてください
3. それでも解決しない場合は、即座にサポートに連絡してください

私の場合、8時間ほど実技を行った後に環境のリセットを行ったところ、環境が起動できなくなりました。サポートに問い合わせた結果、復旧することができ、その後3時間で攻略することができました。

## 私の実際の試験体験

### タイムライン

- **試験日深夜0時〜4時**: PowerShellマニュアルを1周
- **朝6時**: 試験開始
- **最初の1時間**: 初期アクセスからローカル管理者権限の奪取
- **2時間目**: 1台目のサーバーを完全に攻略
- **その後数時間**: 順調に2台目まで攻略
- **6時間経過時点**: 3台目の攻略で詰まってしまい、環境のリセットを実行
- **リセット後**: 環境が起動せず、疲労により2時間ほど仮眠
- **14時頃**: 起床後もリセットされておらず、サポートに問い合わせ
- **17時**: 環境復旧、再開
- **20時頃**: 全サーバーの攻略完了
- **翌日**: 6時間かけてレポート作成

### 実際の苦労と対処法

睡眠不足と長時間の連続作業は思考能力に影響を与えます。私の経験からアドバイスするなら、試験前の十分な休息と、試験中の適切な休憩が非常に重要です。疲れを感じたら短い仮眠をとることも効果的です。

## 効果的な証拠収集と記録

試験中は以下の情報を徹底的に記録することが重要です。
- 実行した各ステップの詳細
- 使用したコマンドとその出力結果
- 重要な画面のスクリーンショット（多ければ多いほど良い）
- 可能であれば操作の動画記録

これらの情報はレポート作成時に非常に役立ちます。特にスクリーンショットは「多すぎる」ということはありません。

## レポート作成

### Sysreptorの活用

レポート作成には[Sysreptor](https://github.com/Syslifters/sysreptor)を使用しました。このツールは専門的なペネトレーションテストレポートを効率的に作成するのに最適です。[デモレポート](https://docs.sysreptor.com/demo-reports/)にあるテンプレートを参考にすることで、流れに沿ってレポートを作成することができました。

### レポートの構成

私の最終レポートは56ページにおよび、そのうち攻撃ツールの詳細な解説に12ページを割きました。レポートは次のような主要セクションで構成されていました。

- エグゼクティブサマリー（概要、発見された誤構成、推奨事項、結論）
- 方法論（目的、範囲、提供されたユーザーアカウントとマシン）
- 侵害パス（各ターゲットシステムごとの詳細な攻撃手法）
- 免責事項
- 付録（Active Directoryセキュリティ評価ツール）

各攻撃パスごとに以下の情報を詳細に記載しました。

1. **脆弱性/誤構成の詳細**: 具体的な問題点とその技術的背景
2. **影響度**: 組織のセキュリティにどのような影響があるか
3. **再現手順**: スクリーンショット付きの詳細なステップバイステップガイド
4. **証拠**: コマンド出力、ハッシュ、フラグなど
5. **推奨される対策**: 問題を修正するための具体的な方法

### 時間管理の重要性

レポート作成には私の場合6時間ほどかかりましたが、これは事前にスクリーンショットや実行コマンドを詳細に記録していたからこそ可能でした。証拠不足でレポート作成に苦労することがないよう、試験中の記録は徹底的に行いましょう。

## 試験の実際とアドバイス

### 効果的な列挙

CRTPの成功の鍵は徹底的な列挙にあります。以下の列挙ポイントを重点的に確認しました。

- ドメインコントローラー情報
- ユーザーアカウントとグループ
- 信頼関係（ドメイン間、フォレスト間）
- サービスアカウント
- グループポリシー
- 共有フォルダとACL
- Kerberos委任設定

### 困難に直面したとき

途中で詰まった場合は、以下のアプローチが有効です。

- 基本に立ち返り、これまでの列挙結果を再確認する
- 別のアングルからの攻撃を試みる
- 一旦休息をとり、頭をリフレッシュする

私自身、3台目のサーバーで詰まった際に環境のリセットを試みましたが、それがかえって問題を複雑にしてしまいました。リセットは最終手段として、まずは異なるアプローチを試すことをお勧めします。

## 最終的な学び

CRTP試験を通じて、Active Directory環境における攻撃手法だけでなく、以下のスキルも向上しました。

- 体系的な問題解決能力
- トラブルシューティングスキル
- レポート作成能力
- 時間管理とプロジェクト計画
- ストレス下での冷静な判断力

特に、試験中の睡眠不足が思考能力に与える影響を実感しました。適切な休息と集中力の管理が、長時間に及ぶ試験では極めて重要です。

## おわりに

CRTPは実践的な資格であり、Active Directoryセキュリティを学ぶ上で非常に価値のある投資です。十分な準備と計画的なアプローチで、皆さんもきっと合格できるでしょう。最後に、試験のポイントをまとめます。

1. 事前にPowerShellツールと攻撃手法に慣れておく
2. 十分な休息をとってから試験に臨む
3. 詳細な列挙を徹底し、攻撃ベクトルを特定する
4. 試験中に詳細なスクリーンショットと記録を取る
5. 問題が発生したらパニックにならず、サポートに連絡する
6. レポート作成には十分な時間をかけ、専門的な品質を目指す

皆さんの挑戦を応援しています！

![Web Certification](/assets/img/post/2025-03-23/image.png)
