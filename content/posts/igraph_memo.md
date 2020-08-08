

---
title: igraph memo
date: 2020-06-10
description: Self memo of igraph + R
tags: ["R", "igraph", "Tips"]
---

<!--This page is a memo to run Selenium from R and do web scraping using RSelenium.-->
## Preface

Rとigraphでネットワークのグラフを書いた時の備忘録です。

動物行動を遷移図として記述すると言う試みは古くからなされているのですが、見やすいグラフをRで描けないかな、と思い立ったのがきっかけです。なのでターゲットは動物行動です。

## Environment
- Mac OS Catalina var. 10.15.4
- [R igraph](https://igraph.org/r/) ver. 1.2.5
- [R](https://www.r-project.org/) ver. 4.0.0


## What's igraph?

igraphはR以外にもネットワークを記述する時に用いられる文法のようなものです。
R以外にPythonやMathmetica、C++などでも動かせます。ggplot2みたいなもの。


## Main Flow
1. Dataの準備
2. ネットワークへ変換の下準備
3. ネットワークの生成
4. 描画


### 1. Data Preparation
今回は仮に2個体での複数の行動の遷移を表す図を作成します。
捕食者と被食者の関係で以下のような行動が見られるとします。

- N: No action
- S: Search by the predator
- A: Attacking by the predator
- D: Defense by the prey
- E: prey is Escaped
- P: Predation

例えば、
N -> S -> A -> D -> E
では「捕食者が探索行動を開始し、捕食者が被食者を発見し、攻撃を開始し、被食者が防御行動を行い、被食者が逃亡する。」を示しています。

S -> A -> D -> A -> P
では「捕食者が探索行動を行っており、攻撃を開始し、被食者が防御行動を行うが、攻撃を再度行い、最終的に捕食を行う。」を示しています。


前者のデータを`SADE`で、後者のデータを`SADAP`で表すとします。
このようなデータがいくつかあるとします。

データの都合上、Pが生じたらそこでこの行動の観察を終了します。行ごとの被食者を統一するためです。
捕食後の捕食者が次の探索行動に移る場合などは別の行で表します。
つまり、行が同じ時は捕食者と被食者が同一であることを示します。NとSでは被食者が出てきませんが...。


```R
library(tidyverse)

dat <- tribble(~beh,"S", "NSADE", "SAP", 
    "NSADE", "MNSADS", "ADASNSADE", "NSAP", 
    "NSADAP", "SNADENAS", "NSADAP")
```
```R
> dat
# A tibble: 10 x 1
   beh
   <chr>
 1 S
 2 NSADE
 3 SAP
 4 NSADE
 5 MNSADS
 6 ADASNSADE
 7 NSAP
 8 NSADAP
 9 SNADENAS
10 NSADAP
```

こんな感じにデータを生成します。
実際のデータはもっと別の形をしている可能性はありますし、観察の設定によっては絶対に解釈が難しいとかもあるでしょうが、今回は目を瞑ります。
例えば、1行目のSだけの行動は観察者が捕食者の探索行動を観察している内に観察を中断した、とかが考えられます。 ~~そんなデータ使わない方が良いとは思いますが...。~~ 


### 2. Data Shaping
`dat`は使い慣れたtibbleの形ですが、igraphはこのままだとデータを受け取ってくれません。

少し変形して、ネットワークのノードとその繋がりであるリンクを作成します。
ノードとはネットワークにおける点（見た目的には円のことが多いかも）のことで、リンクはノードを繋ぐ線で表されることが一般的と思います。以下の図がイメージしやすいかも。

![](https://www.kagoya.jp/howto/wp-content/uploads/kagoya202001-2.png)
引用：https://www.kagoya.jp/howto/rentalserver/node/

先ほどの行動の遷移からノードとリンクを作成します。
ノードは一つの行動（ex. NとかSなど）が相当します。
リンクは行動の遷移（ex. NSやSAなど）が相当します。
また、今回はただのリンクではなく、方向性のあるリンクとなります。遷移なので。




```R
nodes <- dat %>%  
	mutate(N=str_count(beh,"N"),
        S=str_count(beh,"S"), 
		A=str_count(beh,"A"), 
        D=str_count(beh,"D"),
		E=str_count(beh,"E"),
        P=str_count(beh,"P")) %>%
	select(-beh) %>% 
	dplyr::summarize_all(mean) %>%
	t() %>% as.data.frame() %>%
	as_tibble(rownames="id") %>% 
	mutate(beh=c("No action", "Search", "Attack", 
			"Defense", "Escape", "Predation")) %>%
	mutate(behType=c(1,2,2,3,3,2), typeLabel=c("Both", "Predator", 
			"Predator", "Prey", 
            "Prey", "Predator")) %>%
	mutate(nodeSize=V1) %>%
	select(-V1)


links <- dat %>%  
	mutate(NS=str_count(beh, "NS"),
            SN=str_count(beh, "SN"), 
            SA=str_count(beh, "SA"), 
            AD=str_count(beh, "AD"), 
            AS=str_count(beh, "AS"), 
            AP=str_count(beh, "AP"), 
            DP=str_count(beh, "DP"), 
            DA=str_count(beh, "DA"), 
            DE=str_count(beh, "DE"), 
            EN=str_count(beh, "EN")) %>% 
	select(-beh) %>% 
	dplyr::summarize_all(mean) %>%
	t() %>% as.data.frame() %>%
	as_tibble(rownames="transition") %>% 
	mutate(from=str_sub(transition, 1,1)) %>%
	mutate(to=str_sub(transition, 2,2)) %>%
	mutate(weight=V1) %>%
	select(-transition, -V1)
```

__※今回は簡単のため、一連の行動（1行に相当する）の長さについて考えていません。実際には行動のレベルで標準化することが必要かと思います。__

できたものがこちら。

```
> nodes
# A tibble: 6 x 5
  id    beh       behType typeLabel nodeSize
  <chr> <chr>       <dbl> <chr>         <dbl>
1 N     No action       1 Both            0.9
2 S     Search          2 Predator        1.3
3 A     Attack          2 Predator        1.4
4 D     Defense         3 Prey            0.8
5 E     Escape          3 Prey            0.4
6 P     Predation       2 Predator        0.4


> links
# A tibble: 10 x 3
   from  to    weight
   <chr> <chr>  <dbl>
 1 N     S        0.7
 2 S     N        0.2
 3 S     A        0.8
 4 A     D        0.8
 5 A     S        0.2
 6 A     P        0.4
 7 D     P        0
 8 D     A        0.3
 9 D     E        0.4
10 E     N        0.1
```

なんかそれっぽくなってきました。



### 3. Generate Network
ようやく{igraph}の出番です。

```R
library(igraph)

net <- graph_from_data_frame(d=links, vertices=nodes, 
                            directed=T)
```

`graph_from_data_frame()`以外にもnetworkを作成する関数は存在します。興味がある人は`?igraph`で探してみてください。

中身はこんな感じになっています。ここからは完全に{igraph}の独壇場です。

```
> net
IGRAPH a6bd990 DNW- 6 10 --
+ attr: name (v/c), beh (v/c), behType (v/n), typeLabel (v/c), nodeSize
| (v/n), weight (e/n)
+ edges from a6bd990 (vertex names):
 [1] N->S S->N S->A A->D A->S A->P D->P D->A D->E E->N
```

### 4. Drawing the Network
描画するだけならもっと楽です。

```
net %>% plot()
```

これだけです。びっくり。以下のようなグラフが出力されます。
ちなみにこの`plot()`は実は`plot.igraph()`を呼んでいるのでこんな感じに描けるわけです。{igraph}を読み込んでいないと動かないことに注意してください。

![](https://i.imgur.com/DuqYwfb.png)


描けはしましたが、いくつか問題点がありますね。

- どのノードがどのtypeに属しているのかわからない
- リンクが遷移を表すのですが、同じ遷移率のように見えてしまう
- 出力のたびに配置が変わる


と言うことで、以下は描画のtipsです。

主に`igraph::V()`と`igraph::E()`を用います。

前者はノード（vertex）に関するいろいろな操作を、後者はリンク（edge）に関するいろいろな操作を行う関数です。

#### Tips: Node type

`nodes`に`behType`とか`typeLabel`と言うカラムがあります。実はそんなカラムを作成していました。
これは、行動の主体が捕食者なのか被食者なのかそれとも両方なのかを表しています。

せっかくなので色分けすると見やすくなるかもしれません。

```
colr <- c("red", "blue", "green")
V(net)$color <- colr[V(net)$behType]

plot(net)
```

![](https://i.imgur.com/LEIezts.png)

色が変わりました。__本番環境では文字の色との兼ね合いを考えましょう。__

また、各行動がどれくらいの頻度で生じているかを人目見てわかりやすくしたいですね。そういった時は以下のスクリプトで対応できます。


```
V(net)$size <- degree(net, mode="all")*5
plot(net)
```

![](https://i.imgur.com/bJLaDtN.png)

EscapeやPredationはSearchやAttackに比べて生じにくいと言うことがぱっと見でわかると思います。
`*5`の部分はデータによってまちまちなので各自の調節が大切になります。


#### Tips: Link weight
リンクの太さを変えることで、遷移がどこの行動間で生じているのか見やすくしましょう。

```
E(net)$width <- E(net)$weight*10
E(beh_net)$arrow.size <- 2
plot(net)
```

![](https://i.imgur.com/23e0MyL.png)

太さは変わりましたが、両方向に生じる遷移の場合、どちらがより大きいのかわかりません。

この場合はplotで調整します。


```
plot(net, edge.curved=0.3)
```

![](https://i.imgur.com/SyFVmYE.png)


#### Tips: Fixed position
最後に、出力の度にノードの位置が変わってしまう、と言う問題についての対応です。

例えば、ここまでの図を見比べてみてもらっても、ノードが毎回バラバラなことがよくわかります。


これは`plot()`の`layout`オプションで対処できます。
`layout`オプションは、指定された位置にノードを配置するためのものです。

配置するためのmatrixを作る関数は`layout_()`です。ややこしいですね。
以下のように使います。
```
lo <- layout_(net, as_star())
plot(net, layout=lo, edge.curved=0.3)
```

![](https://i.imgur.com/MHW99Dx.png)


`as_star()`は一つのノードを真ん中に配置し、それ以外を周囲に配置します。
他にも、`as_bipartite()`でリンクの交差を最小にしたり、`as_tree()`で木構造のような配置にすることも可能です。
他にもオプションはあります。`?layout`で調べてください。


一度作成した`lo`を再度用いることで再現性が担保されます。


~~オプションの順番依存で再現できなかったりできたりする...？~~
このような問題が生じていましたが、再度確認したところ見つかりませんでした。


## Postface
自分用のメモと言うことで書きました。また散文です。

{igraph}は関数も割と多く、これだけで満足しました。まだまだ使っていない機能が多いので、そのうち遊びたいです。3D plotとかinteractive plotとか。




Enjoy!




