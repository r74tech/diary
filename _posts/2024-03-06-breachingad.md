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

```bash
$ THMDCIP=10.200.28.101
$ systemd-resolve --interface breachad --set-dns $THMDCIP --set-domain za.tryhackme.com
```

---

Task 1
