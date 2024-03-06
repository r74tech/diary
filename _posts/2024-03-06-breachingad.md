---
title: Breaching Active Directory
author: r74tech
categories:
  - tryhackme
tags:
  - thm
  - ad
math: false
mermaid: false
slug: 2024-03-06-breachingad
image:
  path: ./assets/img/og/2024-03-06-breachingad.png
  show: false
---
## 邦訳: Active Directoryへの侵入

ADの設定ミスをついて特権昇格や横断的移動、目的実行などを行うにはまず、初期アクセスが必要となる。

このRoomでは、ADに侵入するための方法をいくつか紹介する。

- NTLM認証サービス
- LDAPバインド資格情報
- 認証リレー
- Microsoft Deployment Toolkit
- 設定ファイル

---

## Task 1

まずは、ネットワーク内の特定のサーバーやリソースにアクセスするために必要な名前解決を行う設定から始める。これにより、ドメイン名をIPアドレスに変換し、ネットワーク通信の正しいルーティングを確保する。

![Untitled](/assets/img/post/2024-03-06/Untitled.png)

下記のコマンドは、この名前解決プロセスを設定するために使用され、`THMDCIP`変数には、TryHackMeのドメインコントローラーのIPアドレスが格納され、このアドレスがDNSサーバーとして機能する。これにより、`za.tryhackme.com`ドメイン内のホストに対するクエリが正確に解決され、タスクやチャレンジに必要なネットワークリソースへのアクセスが可能になる。

```bash
$ THMDCIP=10.200.28.101
$ systemd-resolve --interface breachad --set-dns $THMDCIP --set-domain za.tryhackme.com
```

| コマンド部分 | 説明 |
| --- | --- |
| systemd-resolve | DNS設定やクエリ実行に関するコマンドラインツール |
| --interface breachad | 操作を適用するネットワークインターフェースを指定 |
| --set-dns $THMDCIP | 使用するDNSサーバーのIPアドレスを設定 |
| --set-domain za.tryhackme.com | 検索ドメインを設定 |

※ 検索ドメイン: FQDNではないホスト名に対して自動的に追加されるドメイン。

---
