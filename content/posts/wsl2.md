---
title: tidyverse on wsl2
date: 2022-12-10
tags: [tag1, tag2]
---

# tidyverse on wsl2

R 4.xとtidyverseをwsl2で動かすメモです。Windows初心者なので色々間違っているかもしれません。

使ったPCは[こちら](https://www.amazon.co.jp/dp/B07Y9Z83JC?ref_=cm_sw_r_cp_ud_dp_9P5JNMGRSRYTC6GTJRBZ)
OS：Windows 11 Pro


## wsl2のインストール
1. コマンドプロンプトを管理者権限で実行
2. コマンドプロンプトで`wsl --install`
3. 再起動

ここまでは多くの記事があるのではしょりましたが、大きく分けると上記の3段階です。

## R 4.xのインストール

おそらく何もしていなければUbuntuが入っていると思います。その他の環境については今回は調査していません。

コマンドプロンプトで以下を実行。

```sh=
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/'
sudo apt install r-base
R --version
```

参照：https://medium.com/@hpgomide/how-to-update-your-r-3-x-to-the-r-4-x-in-your-linux-ubuntu-46e2209409c3#:~:text=How%20to%20update%20R%203.x%20to%20the%20new,3.x%20packages%20to%20the%20new%204.0.%20See%20More.

## tidyverseのインストール
ここからはおそらくwindowsのいじり具合に依存して色々違うと思います。今回は購入後すぐに試したのでまっさらな状態です。

まずは手始めにtidyverseのインストールを試みます。
```r=
install.packages("tidyverse")
```
きっと大量のerrorが返ってきてtidyverseもインストールできないと思います。Rで以下を打って確認しましょう。
```r=
warnings()
```
そうすると
```r=
installation of package 'hogehoge' had non-zero exit status
```
みたいなものがたくさん出てくると思います。tidyverseを構成するパッケージがインストールできていないというerrorです。

ひとまず、自分の環境では以下をコマンドプロンプトで実行することで解決しました。

```sh=
sudo apt install libxml2-dev
sudo apt install libssl-dev
sudo apt install libcurl4-openssl-dev
```

ここまでをaptでインストールした後、再度Rに入って以下を実行します。
```r=
install.packages("tidyverse")
```


ここまででtidyverseが入っていて使えました。


ただし、`library(tidyverse)`でインストールすると
```R=
System has not been booted with systemd as init system (PID 1). Can't operate.
Failed to connect to bus: Host is down
```
   
といったwarningsがでるかもしれません。
warningsなので気にしなくてもいいんでしょうが気になります。
対象方法は以下。

## systemdを1番目のプロセスとして起動する

```sh=
cd
sudo apt install daemonize
sudo apt-get install -y gpg
wget -O - https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o microsoft.asc.gpg
sudo mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/
wget https://packages.microsoft.com/config/ubuntu/20.04/prod.list
sudo mv prod.list /etc/apt/sources.list.d/microsoft-prod.list
sudo chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg
sudo chown root:root /etc/apt/sources.list.d/microsoft-prod.list
sudo apt-get update; \
   sudo apt-get install -y apt-transport-https && \
   sudo apt-get update && \
   sudo apt-get install -y dotnet-sdk-3.1

wget https://github.com/arkane-systems/genie/releases/download/1.26/systemd-genie.deb
sudo apt-get update; \
  sudo apt-get install -y apt-transport-https && \
  sudo apt-get update && \
  sudo apt-get install -y aspnetcore-runtime-3.1
  
sudo dpkg -i systemd-genie.deb 
```

参照：https://qiita.com/toroi-ex/items/86be61be9b63f4dac5f3

