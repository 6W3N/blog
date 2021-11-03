---
title: ggraph memo
date: 2020-07-30
tags: ["R", "ggraph", "Tips"]
description: Self memo of ggraph + R
---


<!--This page is a memo to run ggraphs from R.-->
## Preface

Rとggraphでネットワークのグラフを書いた時の備忘録です。
[Igraph Memo](https://6w3n.github.io/posts/igraph_memo/)の続編です。

というのも、「{igraph}は{ggplot2}のように図の重ね合わせができない」という問題に当たったためです。
それを解決するために{ggraph}を用いました。そのメモです。

## Environment
- Mac OS Catalina ver. 10.15.4
- [R ggraph](https://cran.r-project.org/web/packages/ggraph/ggraph.pdf) ver. 2.0.3
- [R](https://www.r-project.org/) ver. 4.0.2


## What's ggraph?

ものすごく大雑把な説明をしてしまうと、{ggraph}は{ggplot2}のようにネットワークの視覚化などを行うためのパッケージです。


## Main Flow
1. Dataの準備
2. ネットワークへ変換の下準備
3. ネットワークの生成
4. 描画


上記1.と2.は[Igraph Memo](https://6w3n.github.io/posts/igraph_memo/)と全く同じです。読み飛ばしてもらっても構いません。

今回は3.と4.をメインにやります。

### 1. Data Preparation

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


### 2. Data Shaping

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


### 3. Generate Network
{ggraph}の出番です。

```R
library(ggraph)

net <- graph_from_data_frame(d=links, vertices=nodes, 
                            directed=T)
```

勘の良い方は気づいているかもしれませんが、`graph_from_data_frame()`は{igraph}の関数です。{ggraph}を呼ぶときに{igraph}モインポートしています。


### 4. Drawing the Network

描画はこんな感じ。

```
lo <- matrix(c(50,50,50,100,100,100,80,45,10,50,90,0), ncol=2)	#fixed position

net_plot <- net %>% ggraph(layout = lo) +
	geom_edge_arc(aes(edge_width = weight), 
		edge_colour = "gray", 
		arrow= arrow(length = unit(10, 'mm')),
		strength=0.3, 
		start_cap = circle(30, 'mm'), 
		end_cap = circle(10, 'mm')) +
	geom_node_point(aes(size = nodeSize, color=behType)) + 
	scale_size(range = c(2,20)) +
	geom_node_text(aes(label = beh), 
		repel = F) +
	theme_void() +
	theme(plot.margin = unit(c(3,3,3,3), "lines")) 

net_plot
```

描いたものがこちら。
![](https://i.imgur.com/EUWzF9g.png)

{igraph}の時と異なり、直感的に色々と弄れるイメージがあります。

以下、できる範囲での関数の解説。

- `ggraph()`: 主役。`ggplot()`と異なり、aestheticsはノードとエッジと分があるので、ここでは指定しない。また、`ggplot()`と同じように`+`でつなげていく。
- `geom_edge_arc()`: エッジをArcsで配置する。似たような関数に、`geom_edge_bend()`などがある。
	- start_cap: ノードとエッジ（始点）の間の距離
	- end_cap: ノードとエッジ（終点）の間の距離
- `geom_node_text()`: ノードのテキストは`geom_node_point()`の引数で与えるわけではない。
- `theme()`: {ggplot2}系と同じように`theme()`を用いて全体の微修正ができる。


## Postface
自分用のメモと言うことで書きました。また散文です。

{ggraph}を使った理由の一つに、{ggpubr}との組み合わせで複数ネットワークを一枚にまとめたかったという思いがあります。
{igraph}では描画した図表をいちいち切りそろえて結合して...という作業になるので、それをオートマティックにやりたいというところです。

概念的には以下のような感じ。

```
net_1 <- net %>% ggraph(layout = lo) +
	geom_edge_arc(aes(), ...) +
	geom_node_point(aes(), ...) + 
	geom_node_text(aes(), ...)

net_2 <- net %>% ggraph(layout = lo) +
	geom_edge_arc(aes(), ...) +
	geom_node_point(aes(), ...) + 
	geom_node_text(aes(), ...)


ggpubr::ggarange(net1, net2, 
	labels=c("net1", "net2"),
	nrow=2, ncol=1)

```


Enjoy!







