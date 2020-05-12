---
title: Ready to use EDM on R
date: 2020-04-13
description: MEMO -the preparation for running rEDM using EC2-
tags: ["R", "EDM", "AWS", "Tips"]
---

I wrote <a href="https://hackmd.io/s/S1GyU2c5V">MEMO</a> that the preparation for running rEDM using EC2.  
- EDM: Emprical Dynamic Modeling
- rEDM: R packages using EDM
- EC2(Official name: Amazon Elastic Compute Cloud): one of the AWS platforms.
The above MEMO focuses on after establishing an instance on EC2.


---
The following text is the clone of the above MEMO.

## How to use rEDM in AWS(EC2) -MEMO-

This entry describes the preparation for running rEDM using EC2.

## Connect instance in AWS(EC2)
- Login to [EC2](https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Instances:)
- Make instance (This page is supporting only for Ubuntu)
- Click to "CONNECT"
- Excute following command in directory, which has .pem file
    ```
    ssh -i "hogehoge.pem" ubuntu@hugahuga.compute.amazonaws.com
    ```

## File(or Directory) import (local to AWS)
```
scp -i ./hogehoge.pem -r [directories] ubuntu@hugahuga.compute.amazonaws.com:~/mydir/
```

## Update R
- Check codename of Ubuntu
    ```
  lsb_release -cs
  ```
- Register the mirror site of the download source by adding at <b>/etc/apt/sources.list</b>
    ```
    echo -e "\n## For R package"  | sudo tee -a /etc/apt/sources.list
    echo "deb https://cran.ism.ac.jp//bin/linux/ubuntu $(lsb_release -cs)-cran35/" | sudo tee -a /etc/apt/sources.list
    ```
    - cran35 means that a repository providing R 3.5.x for bionic
- Register the public key
    ```
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
    ```
- And then <b>apt-get</b>
    ```
    sudo apt update
    sudo apt-get install r-base
    ```


Ref
- [Qiita -最新のRをUbuntuにインストール-](https://qiita.com/JeJeNeNo/items/43fc95c4710c668e86a2)

## rEDM installation
### Preparations in advance
- Install curl and xml and ssl on linux
    ```
    sudo apt-get install libcurl4-openssl-dev
    sudo apt-get install libxml2-dev    
    sudo apt-get install libssl-dev
    ```

### rEDM installation
```
install.packages(remotes)
remotes::install_github("ha0ye/rEDM")
library(rEDM)
```

#### !!caution!!
rEDM latest version(190422) <b>DOESN'T</b> have <b><i>twin surrogate method</i></b> by default...
So if you would like to use this method, 1. install <b>rEDM ver.0.7.1</b>, or 2. read <b>data_transformations.R</b>

Refs
- [Thiel et al., 2006](https://iopscience.iop.org/article/10.1209/epl/i2006-10147-0/pdf)
- [Nakayama et al., 2015](https://www.jstage.jst.go.jp/article/seitai/65/3/65_KJ00010198786/_pdf)


1. install rEDM ver.0.7.1

    ```
    install.packages("repmis")
    library(repmis)
    InstallOldPackages(pkgs = "rEDM", versions = "0.7.1")
    ```


2. read [data_transformations.R](/9e2Pb_-dQbSqjSWFUnQdLA)
    1. create data_transformations.R by copy & paste above page
    2. and then read this file

        ```   
        source(data_transformations.R)
        ```


Refs
- [R パッケージ：　古いバージョンをインストールするには](https://blogs.yahoo.co.jp/igproj_fusion/20270891.html)
- [Github](https://github.com/ha0ye/rEDM)
