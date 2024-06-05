---
title: Golden SAMLを利用したAzure ADへの初期アクセス (ADDS, ADCS構築編)
author: r74tech
categories:
  - wip
tags:
  - wip
math: false
mermaid: false
slug: 2024-06-05-active-directory-init
image:
  path: /assets/img/og/2024-06-05-active-directory-init.png
  show: false
---

## ADDS構築
### 0. 事前準備

1. ホスト名を`ADDC`に変更する
```powershell
Rename-Computer -NewName "ADDC"
```

2. IPアドレスを`192.168.10.100`に変更する
```powershell
Get-NetIPAddress | New-NetIPAddress -AddressFamily IPv4 -IPAddress 192.168.10.100 -PrefixLength 24
```
![image](/assets/img/post/2024-06-05/adds00/001.png)
インターネットアダプターが複数ある場合は、`InterfaceIndex`を指定して変更する
```powershell
Get-NetIPAddress | New-NetIPAddress -InterfaceIndex 4 -AddressFamily IPv4 -IPAddress
```
参考: ネットワークアダプタの確認/設定
`Get-NetAdapter`: ネットワークアダプタの一覧を表示する
```powershell
Get-NetAdapter
Name                      InterfaceDescription                    ifIndex Status       MacAddress             LinkSpeed
----                      --------------------                    ------- ------       ----------             ---------
Ethernet0                 Intel(R) 82574L Gigabit Network Conn...       4 Up           00-0C-29-3D-5E-1F         1 Gbps
```


### 1. Active Directoryの機能を有効化する
1. Windows Server 2019上で「サーバーマネージャー」を開き、右上の「管理」> 「役割と機能の追加」をクリックする
![image](/assets/img/post/2024-06-05/adds01/001.png)

2. 「役割と機能の追加ウィザード」が表示されるので、「次へ」をクリックする
![image](/assets/img/post/2024-06-05/adds01/002.png)

3. 「インストールの種類」で「役割ベースまたは機能ベースのインストール」を選択し、「次へ」をクリックする
![image](/assets/img/post/2024-06-05/adds01/003.png)

4. 「サーバーの選択」で「サーバー」を選択し、対象のサーバーを選択し、「次へ」をクリックする
![image](/assets/img/post/2024-06-05/adds01/004.png)

5. 「役割の選択」で「Active Directory ドメインサービス」を選択する
![image](/assets/img/post/2024-06-05/adds01/005.png)

6. ポップアップが表示されるので「機能の追加」をクリックする
![image](/assets/img/post/2024-06-05/adds01/006.png)

1. このタイミングで「DNSサーバー」もインストールする
![image](/assets/img/post/2024-06-05/adds01/007.png)

8. 同じようにポップアップが表示されるので「機能の追加」をクリックする
![image](/assets/img/post/2024-06-05/adds01/008.png)

9. 「機能の選択」では追加するものはないので「次へ」をクリックする
![image](/assets/img/post/2024-06-05/adds01/009.png)

10. 「Active Directory ドメインサービス」の説明が表示されるので「次へ」をクリックする
![image](/assets/img/post/2024-06-05/adds01/010.png)

11. 「DNSサーバー」の説明が表示されるので「次へ」をクリックする
![image](/assets/img/post/2024-06-05/adds01/011.png)

12. 「インストールオプション」で「再起動後に自動的に必要なサービスを追加する」はチェックを入れ、「インストール」をクリックする  
今回は撮影のためにチェックを入れていないが、実際にはチェックを入れることを推奨する
![image](/assets/img/post/2024-06-05/adds01/012.png)

13. インストールが完了すると「構成が必要です。`HOST`でインストールが正常に完了しました」と表示されるので、「閉じる」をクリックする
![image](/assets/img/post/2024-06-05/adds01/013.png)

14. サーバーマネージャーの「通知」に展開後構成タスクが表示されるので、「このサーバーをドメイン コントローラーに昇格する」をクリックする
![image](/assets/img/post/2024-06-05/adds01/014.png)

15. 「配置構成」で「新しいフォレストの追加」を選択し、「ルートドメイン名」を入力し、「次へ」をクリックする  
ここでは`r74tech.local`を入力している。今回はEntra ADとのハイブリッド環境を構築するため、TLDは`.local`を使用し、最終的に代替UPNを設定する予定である。
![image](/assets/img/post/2024-06-05/adds01/015.png)

16. 「ドメインコントローラーオプション」で「ディレクトリサービスの復元パスワード」を入力し、「次へ」をクリックする
  * フォレストの機能レベル: Windows Server 2016  
    今回はWindows10, Windows Server 2019の環境を構築するため、Windows Server 2016のままで問題ない
  * ディレクトリサービスの復元パスワード: 復元パスワードを入力する  
    復元パスワードはドメインコントローラーの復元時に使用するため、忘れないように注意する
![image](/assets/img/post/2024-06-05/adds01/016.png)

17.  DNS委任を行わない場合は「次へ」をクリックする
![image](/assets/img/post/2024-06-05/adds01/017.png)

18.  「追加のオプション」で「次へ」をクリックする  
「[NetBIOS ドメイン名](#NetBIOS)」は自動入力されるため、入力する必要はない
<span id="NetBIOS"></span>
![image](/assets/img/post/2024-06-05/adds01/018.png)

19. 「データベースのフォルダー」「ログファイルのフォルダー」「SYSVOLフォルダー」の場所を確認し「次へ」をクリックする。
![image](/assets/img/post/2024-06-05/adds01/019.png)

20. 「オプションの確認」で設定内容を確認し、「次へ」をクリックする
![image](/assets/img/post/2024-06-05/adds01/020.png)

21.  「前提条件のチェック」でエラーがないことを確認し、「インストール」をクリックする
![image](/assets/img/post/2024-06-05/adds01/021.png)

22. インストールが完了すると「このサーバーはドメインコントローラーとして正常に構成されました」と表示されるので、「閉じる」をクリックする。再起動を促されるので「再起動」をクリックする
![image](/assets/img/post/2024-06-05/adds01/022.png)

23. 再起動後、`Ctrl + Alt + Delete`を押し、`<NetBIOS ドメイン名>\Administrator`でログインする
![image](/assets/img/post/2024-06-05/adds01/023.png)

### 2. ドメインユーザーの作成
1. サーバーマネージャーの「ツール」>「Active Directory ユーザーとコンピューター」をクリックする
![image](/assets/img/post/2024-06-05/adds02/001.png)

1. `r74tech.local`を右クリックし、「新規作成」から「組織単位」を選択し、AD用のOUを作成する
![image](/assets/img/post/2024-06-05/adds02/002.png)

1. 「名前」に組織で識別可能なわかりやすい名前を入力し、「OK」をクリックする
![image](/assets/img/post/2024-06-05/adds02/003.png)

1. 作成したOUを右クリックし、「新規作成」>「ユーザー」をクリックする
![image](/assets/img/post/2024-06-05/adds02/004.png)

1. 「姓」か「名」のいずれかにに識別可能なわかりやすい名前を入力し、「ユーザーログオン名」にも同じように入力し、「次へ」をクリックする
![image](/assets/img/post/2024-06-05/adds02/005.png)

1. 「パスワード」を入力し、「次へ」をクリックする  
「パスワードを無期限にする」のみチェックを入れておく
![image](/assets/img/post/2024-06-05/adds02/006.png)

1. 問題なければ「完了」をクリックする
![image](/assets/img/post/2024-06-05/adds02/007.png)

1. 作成したOU配下にユーザーが作成されていることを確認する
![image](/assets/img/post/2024-06-05/adds02/008.png)


## ADCS構築
### 0. ADCSをADに参加させる

#### ADDSの操作

1. サーバーマネージャーの「ツール」>「Active Directory ユーザーとコンピューター」をクリックする
![image](/assets/img/post/2024-06-05/adds02/001.png)

1. AD用のOUを右クリックし、「新規作成」>「ユーザー」をクリックする
![image](/assets/img/post/2024-06-05/adcs00/002.png)

1. ADCS用のユーザーを作成する  
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

1. 「他のユーザーでログイン」をクリックし、サインイン先が[NetBIOS ドメイン名](#NetBIOS)になっていることを確認し、ログインする
![image](/assets/img/post/2024-06-05/adcs00/019.png)


### 1. 証明書サービスのインストール
1. サーバーマネージャーの「管理」>「役割と機能の追加」をクリックする
2. 「役割と機能の追加ウィザード」が表示されるので、「次へ」をクリックする
3. 「インストールの種類」で「役割ベースまたは機能ベースのインストール」を選択し、「次へ」をクリックする
4. 「サーバーの選択」で「サーバー」を選択し、対象のサーバーを選択し、「次へ」をクリックする
5. 「役割の選択」で「Active Directory 証明書サービス」を選択する
