---
title: '[wip] Breaching Active Directory'
author: r74tech
categories:
  - tryhackme
tags:
  - Active Directory
  - thm
  - wip
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

## Task 1: Introduction to AD Breaches

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


- I have completed the AD basics room and am ready to learn about AD breaching techniques.
```
No answer needed
```

- I have connected to the network and configured DNS.
```
No answer needed
```


## Task2: OSINT and Phishing


- I understand OSINT and how it can be used to breach AD(ADを侵害するために使用できるOSINTを理解している)
```
No answer needed
```

- I understand Phishing and how it can be used to breach AD(ADを侵害するために使用できるフィッシングを理解している)
```
No answer needed
```

- What popular website can be used to verify if your email address or password has ever been exposed in a publicly disclosed data breach?
(自分のメールアドレスやパスワードが、一般に公開されたデータ流出事件で流出したことがあるかどうかを確認するために、人気のあるウェブサイトはなんだろうか？)
```
HaveIBeenPwned
```

## Task 3: NTLM Authenticated Services

- What is the name of the challenge-response authentication mechanism that uses NTLM?(NTLMを使用したチャレンジ-レスポンス認証メカニズムの名前は何か？)
```
NetNtlm
```

- What is the username of the third valid credential pair found by the password spraying script?(パスワードスプレーのスクリプトで見つかった3番目の有効な資格情報のユーザー名は何か？)
```
gordon.stevens
```

- How many valid credentials pairs were found by the password spraying script?(パスワードスプレーのスクリプトで見つかった有効な資格情報のペアは何組か？)
```
4
```

- What is the message displayed by the web application when authenticating with a valid credential pair?(有効な資格情報のペアで認証すると、[Webアプリケーション](http://ntlmauth.za.tryhackme.com)に表示されるメッセージは何か？)
```
Hello World
```

## Task 4: LDAP Bind Credentials

- What type of attack can be performed against LDAP Authentication systems not commonly found against Windows Authentication systems?
```
LDAP Pass-back Attack
```

- What two authentication mechanisms do we allow on our rogue LDAP server to downgrade the authentication and make it clear text?
```
LOGIN,PLAIN
```

- What is the password associated with the svcLDAP account?
```
tryhackmeldappass1@
```

## Task 5: Authentication Relay

- What is the name of the tool we can use to poison and capture authentication requests on the network?
```
Responder
```

- What is the username associated with the challenge that was captured?
```
svcFileCopy
```

- What is the value of the cracked password associated with the challenge that was captured?
```
FPassword1!
```


## Task 6: Microsoft Deployment Toolkit

- What Microsoft tool is used to create and host PXE Boot images in organisations?
```
Microsoft Deployment Toolkit
```

- What network protocol is used for recovery of files from the MDT server?
```
TFTP
```

- What is the username associated with the account that was stored in the PXE Boot image?
```
svcMDT
```

- What is the password associated with the account that was stored in the PXE Boot image?
```
PXEBootSecure1@
```

- While you should make sure to cleanup you user directory that you created at the start of the task, if you try you will notice that you get an access denied error. Don't worry, a script will help with the cleanup process but remember when you are doing assessments to always perform cleanup.
```
No answer needed
```

## Task 7: Configuration Files

- What type of files often contain stored credentials on hosts?
```
Configuration Files
```

- What is the name of the McAfee database that stores configuration including credentials used to connect to the orchestrator?
```
ma.db
```

- What table in this database stores the credentials of the orchestrator?
```
AGENT_REPOSITORIES
```

- What is the username of the AD account associated with the McAfee service?
```
svcAV
```

- What is the password of the AD account associated with the McAfee service?
```
MyStrongPassword!
```

## Task 8: Conclusion

- I understand how configuration changes can help prevent AD breaches.
```
No answer needed
```
