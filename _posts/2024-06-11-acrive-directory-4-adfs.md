---
title: '[wip] Active Directoryの構築 4 (ADFS 中編)'
author: r74tech
categories:
  - wip
tags:
  - wip
  - Active Directory
math: false
mermaid: false
slug: 2024-06-11-acrive-directory-4-adfs
image:
  path: /assets/img/og/2024-06-11-acrive-directory-4-adfs.png
  show: false
---

## AD FS構築
### 2. AD FSの機能を有効化する

1. 右上の「管理」> 「役割と機能の追加」をクリックする
![image](/assets/img/post/2024-06-11/adfs02/001.png)

2. 「役割と機能の追加ウィザード」が表示されるので、「次へ」をクリックする
![image](/assets/img/post/2024-06-11/adfs02/002.png)

3. 「インストールの種類」で「役割ベースまたは機能ベースのインストール」を選択し、「次へ」をクリックする
![image](/assets/img/post/2024-06-11/adfs02/003.png)

4. 「サーバーの選択」で「サーバー」を選択し、対象のサーバーを選択し、「次へ」をクリックする
![image](/assets/img/post/2024-06-11/adfs02/004.png)

5. 「役割の選択」で「Active Directory Federation Services」を選択する
![image](/assets/img/post/2024-06-11/adfs02/005.png)

6. 「機能の選択」はデフォルトのまま「次へ」をクリックする
![image](/assets/img/post/2024-06-11/adfs02/006.png)

7. 「AD FSの概要」が表示されるので、「次へ」をクリックする
![image](/assets/img/post/2024-06-11/adfs02/007.png)

8. 「インストールオプション」で「再起動後に自動的に必要なサービスを追加する」はチェックを入れ、「インストール」をクリックする  
例にもれず、今回はチェックを入れていないが、実際にはチェックを入れることを推奨する  
![image](/assets/img/post/2024-06-11/adfs02/008.png)

9. インストールが完了すると「構成が必要です。`HOST`でインストールが正常に完了しました」と表示されるので、「閉じる」をクリックする
![image](/assets/img/post/2024-06-11/adfs02/009.png)

10.  Windows Server 2019は、Firewallの設定が必要なため、以下のコマンドを実行して設定を行う
```powershell
Get-NetFirewallRule | ? Name -Match AD FS | Set-NetFirewallRule -Enabled True
```
参考: [Windows Server 2019 AD FS 構築でハマるポイント対策](https://www.vwnet.jp/windows/WS19/2019043001/WS19ADFS.htm)  
![image](/assets/img/post/2024-06-11/adfs02/010.png)

11.  右上の通知アイコンをクリックし、「展開後の構成タスク」> 「このサーバーにフェデレーションサービスを展開する」をクリックする
![image](/assets/img/post/2024-06-11/adfs02/011.png)

1.  「フェデレーションサービスの展開」が表示されるので、「フェデレーションサーバー ファームに最初のサーバーを作成する」を選択し、「次へ」をクリックする
![image](/assets/img/post/2024-06-11/adfs02/012.png)

1. 「Active Directoryドメインサービスへの接続」で構成を実行するユーザーを指定する。
今回は、事前に作成した`r74tech\ADFS`アカウントで権限を付与しているため、このままで問題ない  
![image](/assets/img/post/2024-06-11/adfs02/013.png)

1. 「SSL証明書の選択」で使用する証明書を選択する。  
1.5章で手元に用意した証明書を選択する
![image](/assets/img/post/2024-06-11/adfs02/014.png)
![image](/assets/img/post/2024-06-11/adfs02/015.png)

15. 「フェデレーションサービスの表示名」を入力し、「次へ」をクリックする
![image](/assets/img/post/2024-06-11/adfs02/016.png)

1.  「サービスアカウントの指定」で「KDSルートキーの設定が...」と表示されるため、詳細設定をクリックする
![image](/assets/img/post/2024-06-11/adfs02/017.png)

17. powershellを管理者権限で起動し、以下のコマンドを実行する
```powershell
Add-KdsRootKey -EffectiveTime ((Get-Date).addhours(-10))
```
![image](/assets/img/post/2024-06-11/adfs02/018.png)
![image](/assets/img/post/2024-06-11/adfs02/019.png)

18.  「サービスアカウントの指定」で「グループ管理サービスアカウントを作成する」を選択し、「アカウント名」に識別しやすい名前(今回は`adfs01`)を入力し、「次へ」をクリックする
![image](/assets/img/post/2024-06-11/adfs02/032.png)

19. 「オプションの確認」で設定内容を確認し、「次へ」をクリックする
![image](/assets/img/post/2024-06-11/adfs02/033.png)

20. 「このサーバーは正常に構成されました」と表示されるので、「閉じる」をクリックする
![image](/assets/img/post/2024-06-11/adfs02/034.png)

21. https://localhost/adfs/ls/IdpInitiatedSignOn.aspx にアクセスし、AD FSの動作確認を行う
![image](/assets/img/post/2024-06-11/adfs02/036.png)
![image](/assets/img/post/2024-06-11/adfs02/037.png)
![image](/assets/img/post/2024-06-11/adfs02/038.png)

