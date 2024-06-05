---
title: Active Directoryの構築 2 (ADCS編)
author: r74tech
categories:
  - wip
tags:
  - wip
  - Active Directory
math: false
mermaid: false
slug: 2024-06-05-active-directory-2-adcs
image:
  path: /assets/img/og/2024-06-05-active-directory-2-adcs.png
  show: false
---

## ADCS構築
### 0. ADCSをADに参加させる

#### ADDSの操作

1. サーバーマネージャーの「ツール」>「Active Directory ユーザーとコンピューター」をクリックする
![image](/assets/img/post/2024-06-05/adds02/001.png)

1. AD用のOUを右クリックし、「新規作成」>「ユーザー」をクリックする  
![image](/assets/img/post/2024-06-05/adcs00/002.png)

1. ADCS用のユーザーを作成する  
ここでは、`adcs`というユーザーを作成する  
`ユーザーログオン名`には`adcs`を入力し、「次へ」をクリックする  
![image](/assets/img/post/2024-06-05/adcs00/003.png)
![image](/assets/img/post/2024-06-05/adcs00/004.png)
![image](/assets/img/post/2024-06-05/adcs00/005.png)

1. 作成したADCS用のユーザーを右クリックし、「プロパティ」をクリックする
![image](/assets/img/post/2024-06-05/adcs00/006.png)

1. 「所属するグループ」タブをクリックし、「追加」をクリックする
![image](/assets/img/post/2024-06-05/adcs00/007.png)

1. グループを検索して追加するために、「詳細設定」をクリックする
![image](/assets/img/post/2024-06-05/adcs00/008.png)

1. 共通クエリの名前に「Domain Admins」を入力し、「検索」をクリックし、「Domain Admins」を選択し、「OK」をクリックする  
![image](/assets/img/post/2024-06-05/adcs00/010.png)

1. 同じように「Enterprise Admins」を追加する  
![image](/assets/img/post/2024-06-05/adcs00/009.png)

1. 「OK」をクリックする  
![image](/assets/img/post/2024-06-05/adcs00/011.png)
![image](/assets/img/post/2024-06-05/adcs00/012.png)

1. 「適用」をクリックし、「OK」をクリックして、プロパティを閉じる

参考: `Domain Admins`と`Enterprise Admins`とは
* `Domain Admins`: ドメイン全体の管理者権限を持つグループ
* `Enterprise Admins`: フォレスト全体の管理者権限を持つグループ

ADCSはドメイン全体の管理者権限が必要なため、`Domain Admins`と`Enterprise Admins`に追加する
[参考: Install the Certification Authority](https://learn.microsoft.com/en-us/windows-server/networking/core-network-guide/cncg/server-certs/install-the-certification-authority)

#### ADCSの操作

1. ホスト名を`ADCS`に変更する
```powershell
Rename-Computer -NewName "ADCS"
```

1. IPアドレスを`192.168.10.102`に変更する
```powershell
Get-NetIPAddress | New-NetIPAddress -AddressFamily IPv4 -IPAddress 192.168.10.100 -PrefixLength 24
```
![image](/assets/img/post/2024-06-05/adcs00/013.png)

1. DNSをADDSに向ける
```powershell
Set-DnsClientServerAddress -InterfaceIndex 4 -ServerAddresses 192.168.10.100
```
![image](/assets/img/post/2024-06-05/adcs00/014.png)

1. 「システムの詳細設定」を開き、「コンピューター名」タブをクリックし、「変更」をクリックする  
![image](/assets/img/post/2024-06-05/adcs00/015.png)

1. 「コンピューター名/ドメインの変更」で「ドメインに参加」を選択し、「ドメイン名」に`r74tech.local`を入力し、「OK」をクリックする   
![image](/assets/img/post/2024-06-05/adcs00/016.png)

1. ドメイン参加のためにユーザー名とパスワードを入力し、「OK」をクリックする
![image](/assets/img/post/2024-06-05/adcs00/017.png)

1. 「OK」をクリックする
![image](/assets/img/post/2024-06-05/adcs00/018.png)

1. 「他のユーザーでログイン」をクリックし、サインイン先が[NetBIOS ドメイン名](/posts/2024-06-05-active-directory-1-adds/#NetBIOS)になっていることを確認し、ログインする
![image](/assets/img/post/2024-06-05/adcs00/019.png)


### 1. 証明書サービスのインストール
1. サーバーマネージャーの「管理」>「役割と機能の追加」をクリックする
![image](/assets/img/post/2024-06-05/adcs01/001.png)

1. 「役割と機能の追加ウィザード」が表示されるので、「次へ」をクリックする
![image](/assets/img/post/2024-06-05/adcs01/002.png)

1. 「インストールの種類」で「役割ベースまたは機能ベースのインストール」を選択し、「次へ」をクリックする
![image](/assets/img/post/2024-06-05/adcs01/003.png)

1. 「サーバーの選択」で「サーバー」を選択し、対象のサーバーを選択し、「次へ」をクリックする
![image](/assets/img/post/2024-06-05/adcs01/004.png)

1. 「役割の選択」で「Active Directory 証明書サービス」を選択する
![image](/assets/img/post/2024-06-05/adcs01/006.png)

1. ポップアップが表示されるので「機能の追加」をクリックする
![image](/assets/img/post/2024-06-05/adcs01/005.png)

1. 「機能の選択」では追加するものはないので「次へ」をクリックする
![image](/assets/img/post/2024-06-05/adcs01/007.png)

1. 「Active Directory 証明書サービス」の説明が表示されるので「次へ」をクリックする
![image](/assets/img/post/2024-06-05/adcs01/008.png)

1. 「役割サービスの選択」で「証明機関」を選択し、「次へ」をクリックする
![image](/assets/img/post/2024-06-05/adcs01/009.png)

1. 「インストールオプション」で「再起動後に自動的に必要なサービスを追加する」はチェックを入れ、「インストール」をクリックする  
ここでは、撮影のためにチェックを入れていないが、実際にはチェックを入れることを推奨する
![image](/assets/img/post/2024-06-05/adcs01/010.png)

1. インストールが完了すると「構成が必要です。`HOST`でインストールが正常に完了しました」と表示されるので、「閉じる」をクリックする
![image](/assets/img/post/2024-06-05/adcs01/011.png)

### 2. 証明書サービスの構成
1. サーバーマネージャーの「通知」に展開後構成タスクが表示されるので、「対象サーバーにActive Directory 証明書サービスを構成する」をクリックする
![image](/assets/img/post/2024-06-05/adcs02/012.png)

1. 「資格情報」で`<NetBIOS ドメイン名>\adcs`を入力し、「次へ」をクリックする
![image](/assets/img/post/2024-06-05/adcs02/013.png)

1. 「役割サービスの選択」で「証明機関」を選択し、「次へ」をクリックする
![image](/assets/img/post/2024-06-05/adcs02/014.png)

1. 「CAのセットアップ」で「エンタープライズCA」を選択し、「次へ」をクリックする
![image](/assets/img/post/2024-06-05/adcs02/015.png)

1. 「CAの種類」で「ルートCA」を選択し、「次へ」をクリックする
![image](/assets/img/post/2024-06-05/adcs02/016.png)

1. 「秘密キー」で「新しい秘密キーを作成する」を選択し、「次へ」をクリックする
![image](/assets/img/post/2024-06-05/adcs02/017.png)

1. 「暗号化」では「SHA256」を選択し、「次へ」をクリックする  
基本的には暗号化プロバイダーはデフォルトの`RSA#Microsoft Software Key Storage Provider`から変更する必要はない  
キーの長さは2048ビット以上を推奨し、ハッシュアルゴリズムはMD5などの脆弱なアルゴリズムは使用しない方が良い  
![image](/assets/img/post/2024-06-05/adcs02/018.png)

1. 「CAの名前」では基本的にはデフォルトのままで問題ないが、必要に応じて変更する<span id="CAName"></span>  
![image](/assets/img/post/2024-06-05/adcs02/019.png)

1. 「CAの証明書の有効期間」では「5年」を選択し、「次へ」をクリックする
![image](/assets/img/post/2024-06-05/adcs02/020.png)

1. 「データベースの場所」ではデフォルトのままで問題ないが、必要に応じて変更する
![image](/assets/img/post/2024-06-05/adcs02/021.png)

1. 「概要」で設定内容を確認し、「構成」をクリックする
![image](/assets/img/post/2024-06-05/adcs02/022.png)

1. 「構成が完了しました」が表示されるので、「閉じる」をクリックする
![image](/assets/img/post/2024-06-05/adcs02/023.png)





