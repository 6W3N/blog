---
title: gt
date: 2020-09-10
tags: ["R", "gt", "gtsummary", "Tips"]
description: Self memo to make tables as images using R
---

<!--This page is a memo to male table as image using R.-->
## 導入

論文を執筆する時や、結果をボスに見せる時などに表を作成することがあると思います。
そのような時に皆さんはどのように表を作成していますか？
Excelで作成した表をWordに埋め込む、Wordで直接表を作成する、LaTeXの表組みを用いる、Markdownで記述してpandocで吐き出す...などなどいろいろな方法があると思います。

筆者はもっぱらLaTeXの表組みを用いていました。（筆者はそのうち.Rmdに完全移行したいと思いつつ2年くらいはR+LaTeXの組み合わせを用いています。）

いつものようにRで得た解析結果をぽちぽちとコピペをしていたところ、ふと __「Rで吐き出した解析の結果をコピペする作業、虚しくない？」__ と思い立ったのが本記事のきっかけです。
皆さんはどうですか？胸に手を当てて考えてみてください。~~え、何も思わない？そうですか...。~~

ということで、今回は __Rから表をimageとして吐き出す__ ことを目的とした記事です。imageとして吐き出せば、あとはLaTeXだとて`\includegraphics`でおしまいなわけです。なんと楽なことか。

__注意！！実際問題として、論文を投稿する時にはimageとしてtableを提出できない場合の方が多いと思います。そのような場合もある程度まではカバーできますが、今回は主に学会発表やプログレスミーティングの時のお役立ち情報くらいに考えてください。__
こちらの記事を参照ください。["Can we insert tables as images in a manuscript submission document?"](https://www.researchgate.net/post/Can_we_insert_tables_as_images_in_a_manuscript_submission_document)

また、今回もかなり備忘録に近いです。

今回は、
1. [{gt}による表作成](#gtによる表作成)
2. [{gtsummary}による表作成](#gtsummaryによる表作成)
3. [出力、その他](#出力その他)

の順です。


## Environment
- macOS Catalina 10.15.6
- R 4.0.2
- gt 0.2.2
- gtsummary 1.3.4
- webshot 0.5.2



 
## {gt}による表作成

まずは{gt}パッケージによる表作成から。

{gt}パッケージでは慣れ親しんだtibbleなどからgtオブジェクトを介してきれいな表を作成してくれます。
例えばirisを例にすると

```R
library(tidyverse)
library(gt)

iris %>% gt()
```
これだけです。ブラウザ（Rstudioならviewer）が立ち上がり、下のようなtableが表示されたのではないでしょうか。

![](https://i.imgur.com/Hn4nLA0.jpg)

ちょっと長ったらしいので、データ自体を整形しましょう。

各種の`Sepal.Length`のTOP5を集めて、tableとして表示します。

```R
iris_SLtop5 <- iris %>% group_by(Species) %>% 
	arrange(desc(Sepal.Length)) %>% 
	mutate(rownum=row_number()) %>% 
	filter(rownum<=5) %>% 
	select(-rownum) %>% ungroup()
    
iris_SLtop5 %>% gt()    
```

![](https://i.imgur.com/HVwfega.png)


すでにキレイな見た目に見えます。が、ここからさらに細かく編集していきましょう。


### Title and subtitle

表のタイトルです。習うより慣れろの精神で以下のスクリプトを実行してみてください。

```R
iris_SLtop5 %>% gt() %>%
	tab_header(
		title = "Anderson's Iris Data",
		subtitle = md("_Top 5_ flowers from each species of Sepal.Length value")	
	)
```

![](https://i.imgur.com/qe3HVOr.png)

タイトルがつきました。
`md()`という関数を用いると、Markdown記法で文字をいじることができます。これは便利。

### Footnote

注釈を付け加えましょう。データの出典を記述します。


```R  
iris_SLtop5 %>% gt() %>%
	tab_header(
		title = "Anderson's Iris Data",
		subtitle = md("_Top 5_ flowers from each species of Sepal.Length value")	
	) %>%  
    tab_source_note(
        source_note = "The data were collected by Anderson, Edgar (1935)."
  )
```

![](https://i.imgur.com/HKAw5mP.png)


もうちょっと使い勝手良く注釈を付けたいですよね。それもできます。

```R
SL_longest <- iris %>% group_by(Species) %>%
    summarize(SL_mean=mean(Sepal.Length),
                PL_mean=mean(Petal.Length)) %>%
    ungroup() %>%
    filter(SL_mean==max(SL_mean)) %>%
    pull(Species) %>% 
    as.character()
    
    
iris %>% group_by(Species) %>%
    summarize(SL_mean=mean(Sepal.Length),
                PL_mean=mean(Petal.Length)) %>%
    ungroup() %>%    
    gt() %>%
    tab_footnote(
        footnote = md("The **longest** by Sepal.Length."),
        locations = cells_body(
          columns = vars(SL_mean),
          rows = Species == SL_longest)
  ) %>%
    tab_footnote(
        footnote = md("The **shortest** by Petal.Length"),
        locations = cells_body(
              columns = vars(PL_mean),
              rows = PL_mean == min(PL_mean))
  )
```

![](https://i.imgur.com/Q0yonGv.png)


1つ目の`tab_footnote()`では、先に作成しておいた`SL_longest`に入っている`"virginica"`とのマッチングでSepal.Lengthの平均が最長の種を指定しています。
2つ目の`tab_footnote()`では関数内でPetal.Lengthの平均が最短の種を選択しています。

このような注釈を付け加えるのも数行で済んでしまいます。


### Grouping
ここまでのスクリプトでは`ungroup()`をした後に`gt()`を行っていましたが、groupd_dfのまま`gt()`を行うとどうなるのか見ていきます。

```R
iris_SLtop5 %>% group_by(Species) %>%
    gt()
```

![](https://i.imgur.com/KxCvual.png)

groupごとに表示されてすっきりしました。
~~tidydataで慣れている身からするとむしろnon-tidyでモヤッとする...~~

見やすさは、おそらくtidydataよりもむしろこっち。多分。スライドなどにはこちらの方が使い勝手が良いかもしれません。


## {gtsummary}による表作成

続いて{gtsummary}を用いた表作成です。

{gtsummary}は名前の通り、{gt}を元に作成されたパッケージです。summaryデータを一瞬で表現できるすごいパッケージです。

使い方はこちらもシンプル。これだけです。
```R
library(gtsummary)

iris %>% tbl_summary()
```

![](https://i.imgur.com/TfYq4iT.png)

勝手にまとめてくれた上に表示までしてくれました。すごい。

上記の値、どこかで近しい何かを見たことあるかもしれません。そう、`summary()`を用いた時です。

```R
> iris %>% summary

  Sepal.Length    Sepal.Width     Petal.Length    Petal.Width
 Min.   :4.300   Min.   :2.000   Min.   :1.000   Min.   :0.100
 1st Qu.:5.100   1st Qu.:2.800   1st Qu.:1.600   1st Qu.:0.300
 Median :5.800   Median :3.000   Median :4.350   Median :1.300
 Mean   :5.843   Mean   :3.057   Mean   :3.758   Mean   :1.199
 3rd Qu.:6.400   3rd Qu.:3.300   3rd Qu.:5.100   3rd Qu.:1.800
 Max.   :7.900   Max.   :4.400   Max.   :6.900   Max.   :2.500
       Species
 setosa    :50
 versicolor:50
 virginica :50

```

最小値や最大値、平均などは`tbl_sumamry()`のデフォルトではついてきませんが、個人的には結構満足です。


### with glm
`summary()`がこんなにきれいに描けるならもしやliner modelとかも...と期待してしまいますよね。
__あります。__

まずは単純に`glm()`から。モデル式などなどは適当です。
```R
> model1 <- glm(Sepal.Length~Sepal.Width + Species + Sepal.Width*Species, dat=iris)
> summary(model1)


Call:
glm(formula = Sepal.Length ~ Sepal.Width + Species + Sepal.Width *
    Species, data = iris)

Deviance Residuals:
     Min        1Q    Median        3Q       Max
-1.26067  -0.25861  -0.03305   0.18929   1.44917

Coefficients:
                              Estimate Std. Error t value Pr(>|t|)
(Intercept)                     2.6390     0.5715   4.618 8.53e-06 ***
Sepal.Width                     0.6905     0.1657   4.166 5.31e-05 ***
Speciesversicolor               0.9007     0.7988   1.128    0.261
Speciesvirginica                1.2678     0.8162   1.553    0.123
Sepal.Width:Speciesversicolor   0.1746     0.2599   0.672    0.503
Sepal.Width:Speciesvirginica    0.2110     0.2558   0.825    0.411
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for gaussian family taken to be 0.1933783)

    Null deviance: 102.168  on 149  degrees of freedom
Residual deviance:  27.846  on 144  degrees of freedom
AIC: 187.09

Number of Fisher Scoring iterations: 2
```

これを{gtsummary}で書くとこうなります。

```R
model1 %>% tbl_regression()
```

![](https://i.imgur.com/Chwf2v1.png)

Interceptが欲しい、p-valueは小数点3桁で揃えたい、説明変数は斜体にしたい、などもできます。

```R
model1 %>% tbl_regression(intercept=T,
             pvalue_fun = ~style_pvalue(.x, digits = 3)) %>% 
    italicize_levels()

```

![](https://i.imgur.com/0V2HQ74.png)


他にもいろいろ便利な関数が用意されているようですが、私はまだ使いこなせていません。そのうち勉強して追記します。

参考： https://cran.r-project.org/web/packages/gtsummary/gtsummary.pdf

## 出力、その他

最後に出力の話を少しだけします。

特にRstudio以外でRを動かしている場合、ブラウザが立ち上がって見たら.htmlだったと思います。
ここからの出力の方法はいくつかあるのかな、と個人的には思っています。
ただ今回は画像としての出力が目標でしたのでそちらで進めていきます。

まずは、{webshot}パッケージを読み込みます。このパッケージを用いると（正確にはPhantomJSというアプリケーションを用いると）Rでwebページのスクリーンショットを撮ることができます。

```R
library(webshot)
install_phantomjs()
```
準備はこれで終わりです。

では作成したhtmlのスクリーンショットを撮ってみます。

例えば、一番最後に作成した表を画像として保存したいとします。

```R
model1 %>% tbl_regression(intercept=T,
             pvalue_fun = ~style_pvalue(.x, digits = 3)) %>% 
    italicize_levels() %>%
    as_gt() %>%
    gtsave("hogehoge.png")
```

これで、`hogehoge.png`が作成されていると思います。

先ほど表を作成した時と違うのは`as_gt()`を噛ませていることです。
{gtsummary}の`tbl_regression()`それそのものではgtオブジェクトになっていないようですね。`as_gt()`でgtオブジェクトへ変換した後に`gtsave()`を行ってsaveします。
この`gtsave()`の際に先ほどの{webshot}が要求されます。

また、保存は.png以外にも.htmlや.pdf、.texなども可能です。

そうです。この.texに変換したものをLaTeX中に直接組み込むことで投稿論文にも{gtsummary}の転用が可能になります。（ただし、精度はあまり良くないので吐き出した.texファイルを元に自ら手直しをする必要があります。）

{gtsummary}は、今後も開発が続くようですので、今後に期待ということになると思います。




というわけで、{gt}などを用いて表を画像として出力する方法でした。


enjoy!



