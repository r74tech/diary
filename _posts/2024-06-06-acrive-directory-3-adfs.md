---
title: '[wip] Active Directoryの構築 3 (ADFS編)'
author: r74tech
categories:
  - wip
tags:
  - wip
  - Active Directory
math: false
mermaid: false
slug: 2024-06-06-acrive-directory-3-adfs
image:
  path: /assets/img/og/2024-06-06-acrive-directory-3-adfs.png
  show: false
---

## AD FS構築

### 0. AD FSの準備
AD FS用のアカウントと、AD FS用のサービスアカウントを作成する

1. AD DS, AD CSの時と同じように、AD FS用のユーザーを作成する  
ここでは、`adfs`というユーザーを作成する  
![image](/assets/img/post/2024-06-06/adfs00/001.png)
![image](/assets/img/post/2024-06-06/adfs00/002.png)
![image](/assets/img/post/2024-06-06/adfs00/003.png)
![image](/assets/img/post/2024-06-06/adfs00/004.png)
![image](/assets/img/post/2024-06-06/adfs00/005.png)

1. `adfs`ユーザーを右クリックし、「プロパティ」をクリックして、「所属するグループ」タブをクリックする
![image](/assets/img/post/2024-06-06/adfs00/006.png)
![image](/assets/img/post/2024-06-06/adfs00/007.png)

1. AD FS用のユーザーには`Domain Admins`を追加する  
参考: [Install the AD FS Role Service](https://learn.microsoft.com/en-us/windows-server/identity/ad-fs/deployment/install-the-ad-fs-role-service)  
![image](/assets/img/post/2024-06-06/adfs00/009.png)
![image](/assets/img/post/2024-06-06/adfs00/011.png)

1. AD FS用のサービスアカウントを作成する
![image](/assets/img/post/2024-06-06/adfs00/012.png)
![image](/assets/img/post/2024-06-06/adfs00/013.png)
![image](/assets/img/post/2024-06-06/adfs00/014.png)
![image](/assets/img/post/2024-06-06/adfs00/015.png)

### 1. 証明書の発行
1. 「Windows 管理ツール」>「証明機関」をクリックする
![image](/assets/img/post/2024-06-06/adfs01/001.png)

1. 「証明機関」>「`r74tech-ADCS-CA`([CAの共通名](/posts/2024-06-05-active-directory-2-adcs/#CAName))」>「証明書テンプレート」を右クリックし、「管理」をクリックする  
![image](/assets/img/post/2024-06-06/adfs01/002.png)

1. 「証明書テンプレート」が表示されるので、「Web サーバー」を右クリックし、「テンプレートの複製」をクリックする
![image](/assets/img/post/2024-06-06/adfs01/003.png)
![image](/assets/img/post/2024-06-06/adfs01/004.png)

1. 「新しいテンプレートのプロパティ」が表示されるので、「全般」タブで「テンプレート表示名」を入力する  
「テンプレート名」は表示名で自動的に入力されるため、変更する必要はない  
「有効期間」、「更新期間」は必要に応じて変更する  
![image](/assets/img/post/2024-06-06/adfs01/005.png)

1. 「要求処理」タブで、「秘密キーのエクスポートを許可する」にチェックをいれる
![image](/assets/img/post/2024-06-06/adfs01/006.png)

1. 「セキュリティ」タブで、「追加」をクリックし、**「コンピューター」**に対して「登録」権限を付与する  
この時、AD FSサービスアカウントは「コンピューター」に含まれないが、使用を許可するためにはこの権限が必要である<sup>要検証</sup>  
「適用」をクリックし、テンプレートを保存する
![image](/assets/img/post/2024-06-06/adfs01/007.png)
![image](/assets/img/post/2024-06-06/adfs01/010.png)
![image](/assets/img/post/2024-06-06/adfs01/011.png)
![image](/assets/img/post/2024-06-06/adfs01/013.png)

1. 「証明書テンプレート」を右クリックし、「新規作成」> 「発行する証明書テンプレート」をクリックする  
![image](/assets/img/post/2024-06-06/adfs01/014.png)

1. 先ほど作成したテンプレートを選択し、「OK」をクリックする  
![image](/assets/img/post/2024-06-06/adfs01/015.png)

1. `Certlm`を開く  
![image](/assets/img/post/2024-06-06/adfs01/016.png)

1. `Certlm.msc`が立ち上がるので、左ペインの「証明書 - ローカル コンピューター」>「個人」>「証明書」を右クリックし、「すべてのタスク」>「新しい証明書の要求」をクリックする
![image](/assets/img/post/2024-06-06/adfs01/017.png)

1. 「証明書の要求ウィザード」が表示されるので、「次へ」をクリックする
![image](/assets/img/post/2024-06-06/adfs01/018.png)

1. 「証明書の登録ポリシーの選択」で「Active Directory 登録ポリシー」を選択し、「次へ」をクリックする
![image](/assets/img/post/2024-06-06/adfs01/019.png)
![image](/assets/img/post/2024-06-06/adfs01/020.png)


