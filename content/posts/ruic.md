---
title: rUIC
date: 2022-01-09
tags: [EDM, UIC, CCM, R]
draft: true
---

# [rUIC](https://github.com/yutakaos/rUIC)の備忘録


## UICとは
Unified Information-theoretic Causalityの略。
最近傍法を用いてCCMを解析的（数学的）に解けるように変形し生まれた指標。CCMの一般化とも言える。そのためEDMの一部という立ち位置。


UICのメリット：
- CCMでは線形性が強い際などに偽陽性がでるが、その点に関してUICではロバスト。
- 条件付きで計算できる。そのため、A->B->Cのような因果がある場合、CCMではA->Cでの因果を否定できないが、UICでは否定できる(?)。
- 解析的に計算できるためCCMよりも計算速度が速い。


### rUIC::simplex()
```r
tl <- 400  # time length
x <- y <- rep(NA, tl)
x[1] <- 0.4
y[1] <- 0.2
for (t in 1:(tl - 1)) {  # causality : x -> y
    x[t+1] = x[t] * (3.8 - 3.8 * x[t] - 0.0 * y[t])
    y[t+1] = y[t] * (3.5 - 3.5 * y[t] - 0.1 * x[t])
}
block = data.frame(t = 1:tl, x = x, y = y)
```

```r
simp_yx <- rUIC::simplex(block, 
            lib_var = "y", cond_var = "x", E = 0:8, 
            tau = 1, tp = 1, Enull = "adaptive")
Eyx <- with(simp_yx, max(c(0, E[pval < 0.05])))
```

引数cond_varを指定することで、rUIC::simplex()を行う際に2つの時系列を食わせてやってrmse（だけ!）を求めることができる。そこから　埋め込み次元Eを求める（c.f. rEDM::simplex()は1つの時系列しか入れられない）。UICを計算するとき、2つの時系列の組み合わせで求めたEを他の組み合わせに適用するのは多分ダメ（X+Yで計算したXのEを用いてXとZのUICを計算する、的な）。
2引数でEを求める場合、次元数を一つ増やす操作が必要らしい（uic.optimal()では勝手にやってくれている）。
rmseしか出力結果にないのはUICにおいてrhoとmseが使えないから(?)。
uic.optinal()はバックエンドでこの2引数バージョンのsimplex()を採用している。

ちなみに、rEDM::simplex()で出てくるrhoについては、rhoの値が低い場合（0.1より低いくらい）あまり信用できないらしい。rmseはその辺については大丈夫なよう。Eを実際どのように決めるかについてのガイドラインはいまだにあやふやで、ひとまずrmseが妥当っぽい。


### rUIC::uic.optimal()
```r
uic_opt_yx <- rUIC::uic.optimal(block, 
                    lib_var = "y", tar_var = "x", E = 0:8, 
                    tau = 1, tp = -4:4)
```

Eの計算からやってくれる。Eは上記のrUIC::simplex()のrmseから求められている。
時間遅れtpは普通は0からマイナスにかけて計算する。デモなのでプラスが入っているようだ。

### uic()の結果の見方

```r
gg_uic <- uic_opt_yx %>% mutate(signif=if_else(te>0, "red", "black")) %>% 
        ggplot(aes(x=tp, y=te)) + 
        geom_line() +
        geom_point(aes(y=te, color=signif)) +
        theme(legend.position="none")
```

![](https://i.imgur.com/gdWxMXP.png)


出力で言うところのteがUICに相当する様子。
大雑把に言って、
1. te（UIC）が高く
2. rmseが低い

時間遅れでは因果があると言えるようである。


### rEDM::ccm()との比較
```r
library(foreach)
library(rEDM)
packageVersion("rEDM")
> [1] ‘0.7.1’
```

向峯が慣れているver.0.7.1で比較します。

rEDMは引数tpにvectorを渡せないことに注意！
そのため、foreach()で回します。

```r
ccm_res <- foreach(tp=-4:4, .combine=rbind) %do% {
    rEDM::ccm(block, E=Eyx, 
        tp=tp, lib_sizes=c(Eyx+1, nrow(block)),    
        lib_column="y", target_column="x", 
        silent=T)
    } %>% as_tibble() %>%
    nest(-lib_size, -tp) %>%
    mutate(data=map(data, ~summarize(., 
            sd=sd(rmse, na.rm=TRUE), 
            rmse=mean(rmse, na.rm=TRUE)))) %>% 
    unnest() %>%
    mutate(lib_size=if_else(lib_size==2, "min", "max"))

gg_ccm <- ccm_res %>% ggplot(aes(x=tp, y=rmse, color=lib_size)) +
    geom_line() +
    geom_ribbon(aes(ymin=rmse-sd, ymax=rmse+sd, fill=lib_size), alpha=0.5)
```

![](https://i.imgur.com/OWTOUwN.png)

結果の見方：library sizeがminよりもmaxでrmseが低い時間遅れで因果があると判断できる。加えてsdを計算することでFisher’s ∆ρZ-testをやっていることに相当（するはず）。


グラフを横に並べてみる。


```r
library(ggpubr)

ggarrange(gg_uic, gg_ccm, nrow=1, labels=c("(UIC)", "(CCM)"))
```

![](https://i.imgur.com/V2RqQOE.png)

どちらもtp=-1で最も因果があると判断できる。


### まとめ

- 因果推定の際に用いる上ではCCMよりもUICの方がconservative
- 非線形性が担保されているような状況ではCCMとUICの結果は一致する
- 計算速度はUICの方が速い（今回のデモ程度の長さではあまり感じない）
- 数式的に記述できるUICはCCMよりも説明力が高そう（論文投稿の際とかにUICの方が有利かも）


---

上記の内容は向峯が判断し、記述したものであり、文中の誤り等は全て向峯に責任があります。

もし間違いなどを発見しましたらご連絡くださると助かります。





