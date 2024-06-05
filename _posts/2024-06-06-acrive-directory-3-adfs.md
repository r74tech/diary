---
title: Active Directoryの構築 3 (ADFS編)
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



### 1. 証明書の発行
1. 「Windows 管理ツール」>「証明機関」をクリックする
![image](/assets/img/post/2024-06-06/adcs02/001.png)

1. 「証明機関」>「`r74tech-ADCS-CA`([CAの共通名](/posts/2024-06-05-active-directory-adds-adcs/#CAName))」>「証明書テンプレート」を右クリックし、「管理」をクリックする
![image](/assets/img/post/2024-06-06/adcs02/002.png)

1. 「証明書テンプレート」が表示されるので、「Web サーバー」を右クリックし、「テンプレートの複製」をクリックする
![image](/assets/img/post/2024-06-06/adcs02/003.png)
![image](/assets/img/post/2024-06-06/adcs02/004.png)

1. 「新しいテンプレートのプロパティ」が表示されるので、「全般」タブで「テンプレート表示名」を入力する  
「テンプレート名」は表示名で自動的に入力されるため、変更する必要はない  
「有効期間」、「更新期間」は必要に応じて変更する  
![image](/assets/img/post/2024-06-06/adcs02/005.png)

1. 「要求処理」タブで、「秘密キーのエクスポートを許可する」にチェックをいれる
![image](/assets/img/post/2024-06-06/adcs02/006.png)

1. 「セキュリティ」タブで、「追加」をクリックし、
![image](/assets/img/post/2024-06-06/adcs02/007.png)
![image](/assets/img/post/2024-06-06/adcs02/010.png)
![image](/assets/img/post/2024-06-06/adcs02/011.png)
![image](/assets/img/post/2024-06-06/adcs02/013.png)
