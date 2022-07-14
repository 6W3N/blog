---
title: Writing flow
date: 2022-06-15
tags: ["rmarkdown", "git"]
---


# Rstudioを用いた論文執筆フロー

Rで解析や作図したものを別ファイルとして保存しておき、LaTeXやwordを用いて文章を作成し、共著者とのメールなどをしながらgoogle driveやdropboxでバージョン管理をして...という流れがなんだか非効率的に思えていました。

どうにか一元管理できないかと探していたところ、Rstudio + gitで全て完結しそうだなと思い実際に手を動かしてみた記録です。
簡単に説明すると __Rstudioでrticlesなどの便利packageを用いてRmarkdownを書き、それをgitで管理する__ という方法になります。

この記事の対象はRを用いて作図 -> 論文執筆をしてきた（これからする）くらいの方です。僕の知る進化・生態学系の研究者の方はRを使う機会が多いと思うので、そちら向けと言ってもいいかもしれません。

## TOC
- [構成要素](##構成要素)
- [ディレクトリの作成](##ディレクトリの作成)
- [Rmdの作成](##Rmdの作成)
- [gitでのバージョン管理](##gitでのバージョン管理)
- [gitでの共同編集例](##gitでの共同編集例)
- [おわりに](##おわりに)

## 構成要素

### [Rstudio](https://www.rstudio.com/)
Rユーザーにとっては言わずもがなであるIDE。普段使いしている方も多いと思います。
色々なnvimのプラグインを試した結果、Rmarkdownを書くのにはRstudioが一番適していたので論文執筆時にはお世話になっています。~~（普段の解析はnvimでやっている。）~~

### [Rmarkdown](https://rmarkdown.rstudio.com/lesson-1.html)
Rでドキュメント生成するため、Rとmarkdownを組み合わせたもの。少しややこしいheader部分を除けばRのソースコードとmarkdown記法で全て書けるので非常に楽。
markdownのcheat sheatは[ここ](https://gist.github.com/mignonstyle/083c9e1651d7734f84c99b8cf49d57fa)を参照。

#### 閑話：Rmarkdownで執筆するメリット
主に文章、Rスクリプトがまとまっていることに由来する様々なメリットがあります。
1. __再現性が担保される__ （例：コンパイルするごとに同じグラフを確実に描画できる）。
2. データが変わってもその都度グラフを書き直したり統計解析を行う必要がない（解析結果などを文中で利用できる形にしておけば）。
3. RとRstudio（どちらも無償）が入っていれば互換性が担保される。
4. bibファイルを利用できるため、__引用文献管理が非常に楽__。

反対にデメリットもちらほら
1. Rmdのままでは（基本的には）英文校閲にかけられない。
2. 論文投稿の際にwordファイルを要求される場合、pandocなどを使って一度.docxファイルにする必要がある。~~（これはLaTeXユーザーの常な気がする。）~~

### [rticles](https://github.com/rstudio/rticles)
Rのpackageの一つ。Rmarkdownで文章を執筆する時に、さまざまなジャーナルのテンプレートを使用できる。どんなテンプレートがあるかなどについては[rticles#templates](https://github.com/rstudio/rticles#templates)を参照してください。

### [git](https://ja.wikipedia.org/wiki/Git)
分散型のバージョン管理システム。有名なプラットフォームはgithub。他にもBitbucketやgitlabなど色々ある。いずれも基本的な使い方は変わらない（と思う）ので、以下ではgithubを用いた運用例を載せています。

#### 閑話：gitで管理するメリット
個人的には（もし一人で研究を進めるとしても）研究用のディレクトリをgitで管理することはメリットが大きいと思っています。

1. __データのバックアップ__ を同時に行っているという側面がある。
2. 論文を公開する時にgitのリポジトリを公開すればdata accessibilityに配慮した研究となる。
3. commitのメッセージを見返したりissueを見返すことで、作業の進捗度合いや課題などを思い出すことができる。
4. 共同制作に役立つ小技が多く用意されている（pull request, issue, branchなど...）。

デメリットもいくつかあって
1. 非公開リポジトリを選択しないとデータ流出の恐れがある。
2. 所属機関によってはクラウドサービスを使うことができない可能性。
3. 1ファイルごとの容量制限がある。
4. 共同研究者が使えるとは限らない（！！）

特にデメリットの2.はビデオデータや高画質の画像データなどを扱う場合には顕著に厳しくなると思います。また、デメリットの3.は結構あるかもしれません。~~（使えた方が楽なツールと割り切って勉強してもらってください）~~

## ディレクトリの作成
論文執筆用のディレクトリを作成し、gitに紐つけます。もしくはgithubなどで作成したリポジトリをcloneします。gitを使ったことある方は飛ばしてもらっても良い部分になります。

また、以下のスクリプトはRstudioのConsole PaneのTerminalタブから実行することが多いです。コマンドを書く際にはどこに記述するものか明記するようにするので参考にしてください。

### リモートで作成 -> ローカルにclone
githubの右上の+ボタン > New repositoryをクリックします。

![](https://i.imgur.com/TmIVm3G.png)


- - - 

細々した設定を記入します。
実際の作業に倣い、ここではPrivateを選択しておきます。
Licenseは今回はMITを選びました。

諸々の設定が終わったら一番下のCreate repositoryをクリックしリポジトリを作成します。

![](https://i.imgur.com/ORGUyju.png)

- - - 

こんな感じでリポジトリが作られました。

![](https://i.imgur.com/zbJyQrX.png)

- - - 
右上の緑色のCodeと言われるボタンをクリックすると以下の画像のようにhttpsの情報などが得られます。
![](https://i.imgur.com/FSOur4S.png)

その情報をコピーして、git cloneで引っ張ってきます。

```shell=
## Terminal

cd article    #作成したい場所まで移動する
git clone https://github.com/6W3N/demo.git    #それぞれのhttps情報に差し替えて使ってください。
```

githubのアカウント名やtokenなどを聞かれるのでそれをタイプするとプルできます。


```shell=
## Terminal

cd demo    #今回はdemo repositoryをpullしたのでdemoに移動する
ls    #中身を見る
```

![](https://i.imgur.com/RsZTRPf.png)


ここまでで使用するディレクトリの作成は終了です。



## Rmdの作成
まずはrticlesパッケージをインストールします。

```r=
## Console

install.packages("rticles")
```
これで準備は終了です。
早速Rmdのテンプレートを使いに行きます。


今回はサンプルとしてarXivのテンプレートを用います。各自の投稿したいジャーナルのフォーマットに合わせて適宜修正してください。出版社に合わせたテンプレートもあるのでそちらを使っても良いかもしれません。

Rstudio > File > New File > R Markdown > From Template > arXiv Preprint
の順に選択していきます。
From Templateにない場合は、Rstudioの再起動などを試してみてください。

![](https://i.imgur.com/RzLWEBa.png)

- - - 

![](https://i.imgur.com/CmcZfZI.png)

- - - 
今回、Nameはarxivにしましたが、ここも適宜変更してください。
また、Locationでarxivディレクトリを作成するパスの指定をします。
先ほどプルしてきたdemoの直下に入れます。


すると下記の画像のようにarxivというサブディレクトリが作成されていることが確認できます。
![](https://i.imgur.com/NteBlak.png)

- - - 

arxiv/arxiv.Rmdを選択すると以下のようなファイルが開きます。

![](https://i.imgur.com/SwAjFhx.png)

- - - 
これが論文の雛形になります。
yaml header部分は特に用事がなければ様式を変更しないことをおすすめします。この辺りは沼が深く、筆者もまだまだな分野です。。。

適当に編集しましょう。

![](https://i.imgur.com/kdhXsMH.png)

yaml headerでのいくつかを簡単に説明します。
- title: タイトル。
- authors: 著者情報。段落下げでその詳細（名前とか所属とか）を記述。
- abstract: 概要。
- keywords: キーワード。段落下げリストを書き足すと追加される。
- bibliography: 引用元を集めたbibファイルのファイル名（同じディレクトリ内にある必要がある）。zoteroなど論文管理ツールから一括で吐き出したbibファイルを置き換えておくと便利。
- biblio-style: LaTeXでいうところのbibliographystyle（[参考](https://www.overleaf.com/learn/latex/Bibliography_management_with_bibtex#Reference_guide)）。この項目を消してcslを追加するとかもできる。
- output: どのテンプレートに合わせて出力するか。rticles::arxiv_articleの様に関数を自分で定義すればrticlesにテンプレートがなくても使えるようになる。この話はいずれ。

- - - 

編集が終わったら、Rstudioのknitボタンをクリックするとよしなにコンパイルしてくれます。

![](https://i.imgur.com/CknONAf.png)


Rmdの詳細として[ここ](https://rmarkdown.rstudio.com/lesson-1.html)や[ここ](https://bookdown.org/yihui/bookdown/)を参考に書き進めてください。

文章は文ごとに改行して管理することをおすすめします。1行だけの改行であればコンパイル時にパラグラフとして分かれません。この辺りはどんどんコンパイルしつつ探してみてください。


## gitでのバージョン管理

ある程度書き進めたらgitを用いてgithubにもpushしておきましょう。

基本的には以下のコマンドでpushまで行います。

```shell=
cd ../    #demoに入ります
git add arxiv    #書き進めた文章などを追加します。
git commit -m "add arxiv dir"    #何を追加したのかについて記述します
git push
```

すると以下の図のように追加されてアップロードされます。

![](https://i.imgur.com/kofclYa.png)

- - - 
すると以下の様にgithub上にも反映されます。
arxivディレクトリが追加されていることがわかります。


![](https://i.imgur.com/YM8Vq4t.png)

- - - 

一人でやる場合にはここまでであらかた終わりです。


## githubでの共同編集例
ここからは共同編集のやり方についてです。
二人以上で作業するときはbranchと呼ばれるgitの機能を使うと効率良く作業できます。

筆者もそれほど精通している訳ではなく、現状こうしている、と言う例を載せています。

#### 1. 共同編集者（共著者）のgithubアカウントを追加する。

Repository > Settings > Collaborators > Add peopleの順にクリックします。

![](https://i.imgur.com/XCYnjxu.png)
- - - 
ここで、共著者のgithubアカウントを探します。

![](https://i.imgur.com/pm6oZzb.png)
- - - 
以降は共著者の画面を作るのが面倒だったので文字で説明します。すみません。~~誰か手伝ってください。。。~~

#### 2. 新たなbranchを作成して修正作業を行う（共著者）
まず初めに共著者には自分が作成したレポジトリをpullしてもらいます。

```shell=
git clone https://github.com/6W3N/demo.git
```

その後、最初にbranchをきってもらい、そのbranch上で作業してもらいます。

```shell=
git branch coauthor1comment    #なんでもいいです
git checkout coauthor1comment
```

その後作業（Rmarkdownにコメント; 改変）をしてもらいます。
作業の際にはmarkdown記法を使いこなせるといい感じになります。

#### 3. pushする・pull requestを投げる（共著者）
Rmarkdownへの作業完了後、以下のコマンドで新たなbranchとしてpushします。

```shell=
git add arxiv/arxiv.Rmd
git commit -m "add comment"
git push origin coauthor1comment
```

ここまででgithubに反映されます。

github上でpull requestを投げます。（ここは別にメールでもいいと思います。）

#### 4. pull・mergeを行う（自分）
まずはリモートのbranchをローカルに落とします。

```shell=
git fetch    #リモートのおbranch情報を引っ張ってきます
git branch -a    #リモートのbranchがあるか確認します
git checkout coauthor1comment    #もしあればそのbranchに移動します
git branch    #これでcoauthor1commentが出てくればokです
```

その後、mainにmergeします。

```shell=
git checkout main    #既に入っていたらAlready on 'main'と表示されます
git merge coauthor1comment
```

gitではmergeは行単位で行うので、共著者が編集してくれた部分だけがmergeによって更新されます。

共著者のコメントなどを参考に修正を進めます。

修正を終えたらpushして...
という感じでどんどん進めることができます。


- - - 

## おわりに

ここまで、ひとまず自分がやっているところを紹介してみました。
Rmarkdownの使い心地はかなりよく、wordでちまちま修正するよりも良さそうだな〜と思い最近は専らこのシステムで書いています。

そのうち英文校閲に投げる時のpandocの利用などを書こう...。


Enjoy!


