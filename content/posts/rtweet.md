---
title: Rtweet
date: 2020-08-14
tags: ["R", "rtweet", "Twitter", "Tips"]
description: Self memo of Twitter search by R
---

<!--This page is a memo to run rtweet from R.-->
## Preface

RとrtweetでTwitter APIを叩く備忘録です。

Twitterには見方によって有用な情報が投稿されています。Twitter社はそれらの情報を扱うために、API（Application Programming Interface）と呼ばれるユーザー向けのツールを用意しています。
詳細は[こちら](https://help.twitter.com/ja/rules-and-policies/twitter-api)を参照してください。


APIは申請してから使います。




この備忘録では以下の流れで実行します。

1. rtweet
2. Twitter API
3. rtweet + Twitter API

# Environment
- macOS Catalina 10.15.6
- R 4.0.2
- rtweet 0.7.0
- Twitter Account


## rtweet
{rtweet}はRからTwitterを操作するためのパッケージです。例えば、ツイートのデータを集めたり、ツイートを行ったりすることができます。
これらはTwitterアカウントを連携させて用いることになります。なのでTwitterのアカウントがない場合は[こちら](https://help.twitter.com/ja/using-twitter/create-twitter-account)を参照してアカウントを作成してください。


{rtweet}の使い方自体は至ってシンプルです。

```R
library(rtweet)

post_tweet("Look, i'm tweeting from R in my #rstats! @YOUR_TWITTER_ACCOUNT")
```

__初めて{rtweet}の関数を実行するとブラウザが立ち上がり、Twitterアカウントとアプリとの連携を求めてきます。認証をしましょう。__

さて、上記のスクリプトを実行して自分のTwitterを見てみると...


![](https://i.imgur.com/Rf2SaaI.png)

呟かれています。



次はツイートの検索をしてみます。

```
rstats <- search_tweets(q="#rstats", include_rts = FALSE)

> rstats
# A tibble: 100 x 90
   user_id status_id created_at          screen_name text  source
   <chr>   <chr>     <dttm>              <chr>       <chr> <chr>
 1 608336… 12948646… 2020-08-16 05:12:48 Leilanie95  "Reg… Twitt…
 2 103516… 12948634… 2020-08-16 05:08:08 mdsumner    "#rs… Twitt…
 3 103516… 12948097… 2020-08-16 01:34:24 mdsumner    "#rs… Twitt…
 4 103516… 12948187… 2020-08-16 02:10:12 mdsumner    "#rs… Twitt…
 5 103516… 12948135… 2020-08-16 01:49:37 mdsumner    "#rs… Twitt…
 6 120362… 12948287… 2020-08-16 02:50:06 icymi_r     "📦 \… OneUp…
 7 120362… 12947603… 2020-08-15 22:18:08 icymi_r     "✍️🔤… OneUp…
 8 120362… 12947260… 2020-08-15 20:02:06 icymi_r     "✍️⚡… OneUp…
 9 120362… 12947945… 2020-08-16 00:34:19 icymi_r     "✍️🎨… OneUp…
10 120362… 12948630… 2020-08-16 05:06:28 icymi_r     "✍️👥… OneUp…
# … with 90 more rows, and 84 more variables: display_text_width <dbl>, ...
```


スクリプトの説明をします。
`search_tweets()`はその名の通りツイートを検索する関数です。第一引数のq="#rstat"は、クエリの指定です。今回は#rstatsが含まれるツイートを検索してきています。また、include_rts = FALSEでリツイートを除くというオプションを入れています。
クエリの指定の方法は[公式ページ](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/search/api-reference/get-search-tweets)を参考にしてください。



検索結果が100件だけ...？非常に少ないですよね。
これは`search_tweets()`が何かしていそうです。

[CRAN](https://cran.r-project.org/web/packages/rtweet/rtweet.pdf)にある`search_tweets()`や、Rコンソール上で`?search_tweets()`を実行して説明を読んでみます。


```
> ?search_tweets()

search_tweets              package:rtweet              R Documentation

Get tweets data on statuses identified via search query.

Description:

     Returns Twitter statuses matching a user provided search query.
     ONLY RETURNS DATA FROM THE PAST 6-9 DAYS. To return more than
     18,000 statuses in a single call, set "retryonratelimit" to TRUE.

     search_tweets2 Passes all arguments to search_tweets. Returns data
     from one OR MORE search queries.


Usage:

     search_tweets(
       q,
       n = 100,
       type = "recent",
       include_rts = TRUE,
       geocode = NULL,
       max_id = NULL,
       parse = TRUE,
       token = NULL,
       retryonratelimit = FALSE,
       verbose = TRUE,
       ...
     )
```


なるほど。遡れても6-9日だけとのことです。また、デフォルトではn=100になっていたために、100件しか表示されなかったようです。


では、全期間（2006年以降）のデータにアクセスするにはどうすれば良いのでしょう。
`search_fullarchive()`がそれっぽいです。

```
> ?search_fullarchive()

search_fullarchive           package:rtweet            R Documentation

Search fullarchive (PREMIUM)

Description:

     Search Twitter's 'fullarchive' (PREMIUM) API
```

PREMIUMとはTwitter APIの一つです。[Twitter公式ページ](https://developer.twitter.com/en/products/twitter-api)によれば、API v1.1では下の表のようになっているようです。
Full-archiveがPREMIUM（とEnterprise）でしか使えないことがよくわかります。

![](https://i.imgur.com/rppsVsF.png)
出典：[Twitter公式](https://developer.twitter.com/en/products/twitter-api)


また、`search_tweets()`は{rtweet}の製作者陣が用意してくれていたStandardのAPIを用いていたこともわかります。
全期間を検索するためには __自分で__ 用意したPremiumのAPIを叩かないといけないわけです。

## Twitter API
そもそもTwitter APIを申請するところから始めました。
申請済みの方は読み飛ばしてもらって構いません。


###  APIの申請
Twitterアカウントにログインした状態で、[Developer Tool](https://developer.twitter.com/en/account/environments)にアクセスします。Create an appをクリックして申請などを行います。

![](https://i.imgur.com/21y93dn.png)


その後、以下の項目についてを聞かれるので答えていきます。
- 利用目的
- 住んでいる国
- ニックネーム

この辺りは[こちらのブログ](https://www.itti.jp/web-direction/how-to-apply-for-twitter-api/)を参考にしました。
利用目的は英語での記入になりますが、翻訳サイトなど使えば誰でも記入できると思います。


申請を終えたら、あとはTwitter社からの返事を待ちます。
これがだいぶまちまちで、筆者の例ですと1週間ほどかかりましたが、後輩は数分で返事がきたようです。ネット上の情報を見る限り、1週間で大抵は返事が来るようなので気長に待ちましょう。


## rtweet + Twitter API

### key and token
API申請が受理された後の話です。

[Developer Portal](https://developer.twitter.com/en/portal/)にアクセスします。

+Create AppをクリックしてAppを作成していきます。
![](https://i.imgur.com/nVrgEFl.png)

名前を入力します。今回は、お試しなのでbiological interactionを適当に略した名前を付けました。
CompleteをクリックするとAPI keyなどが表示されます。

![](https://i.imgur.com/NwxzcPo.png)

これら3つの情報は後からでも閲覧できますが、今のうちにコピーを取っておきましょう。
また、詳細は後述しますが、この3つの情報に加えて __access token__ と __access secret token__ の2つが必要になってきます。

サイドナビから、作成したAppの名前をクリックすることでそのAppの詳細を見にいくことができます。

![](https://i.imgur.com/iRcxGav.png)

Appの名前の下にあるKeys and tokensをクリックしてtokenを見にいきましょう。

![](https://i.imgur.com/xfNzyAo.png)


上のスクリーンショットではすでにtokenを生成してしまっていますが、Access Token & Secretの横にあるGenerateをクリックするとtokenが生成されます。
__この2つのtokenはポップアップが出ている状態でしかコピーできません。__
コピーを取っておきましょう。

![](https://i.imgur.com/RBT3ZFB.png)

次にPremiumのための準備を行います。

### Premium API
上述した通り、`search_fullarchive()`を用いるにはPremiumに登録する必要があります。
Premiumにも無料で使える範囲があります。ひとまず無料で使える範囲で使ってみましょう。


サイドナビのAccountの直下にあるBillingをクリックします。ここから、クレジットカードの情報を登録します。一旦登録をしないと無料版を使うつもりだとてPremium APIを叩く権利はないようです...。

登録が済んだら再びサイドナビをみてみましょう。Premiumが追加されていると思います。

![](https://i.imgur.com/Iu0HBgM.png)

このDev Environmentsをクリックして、先ほど作成したAppとPremiumの情報とを紐付けます。下の図はすでに作成していますが、例えばFull-archiveを使いたいのであれば、Full-archiveの右に出ているであろうSet up dev environmentをクリックします。
自分でenvironmentの名前を決め、紐付けたいAppの名前を選択します。

![](https://i.imgur.com/kU9Gztc.png)


Developer Toolにおける準備がようやく終わりました。

### rtweet::search_fullarchive()

Rの画面に戻ります。アクセスの準備をします。

```
library(rtweet)

appname <- "your-app-name"
key <- "yourLongApiKeyHere"
secret <- "yourSecretKeyHere"
broken <- "yourBrokenToken"
access_token <- "yourAccessToken"
access_secret <- "yourAccessSecretToken"
dev_env <- "yourDevEnvironments"
```

上記はDeveloper Toolで得られる情報です。
上から、
- Appの名前
- AppのAPI key
- AppのAPI secret key
- AppのBroken key
- AppのAccess token
- AppのAccess secret token
- 紐付けたDev Environmentの名前

です。

```
twitter_token <- create_token(
	app = appname,
	consumer_key = key,
	consumer_secret = secret,
	access_token = access_token,
	access_secret = access_secret)
```

`create_token()`で上から6つの情報を入れておきます。
そして、作成したtokenを`search_fullarchive()`で呼び出します。と、同時にDev Environmentの名前も必要になります。
ちなみに先ほどの`search_tweets()`と同様にデフォルトでは最大100件までの取得になります。


```
rstats_2019 <- search_fullarchive(q="#rstats", 
			env_name=dev_env,	
            token=twitter_token,
			fromDate="201901010000",
			toDate="201912312359")


> rstats_2019
# A tibble: 100 x 90
   user_id status_id created_at          screen_name text  source
   <chr>   <chr>     <dttm>              <chr>       <chr> <chr>
 1 473324… 12121610… 2019-12-31 23:58:06 grrrck      "As … Twitt…
 2 101181… 12121608… 2019-12-31 23:57:31 rstatstweet "RSt… rstat…
 3 101181… 12121608… 2019-12-31 23:57:31 rstatstweet "\U0… rstat…
 4 101181… 12121608… 2019-12-31 23:57:30 rstatstweet "An … rstat…
 5 101181… 12121531… 2019-12-31 23:26:56 rstatstweet "I w… rstat…
 6 101181… 12121531… 2019-12-31 23:26:56 rstatstweet "Did… rstat…
 7 101181… 12121531… 2019-12-31 23:26:57 rstatstweet "Hap… rstat…
 8 101181… 12121531… 2019-12-31 23:26:56 rstatstweet "A t… rstat…
 9 101181… 12121494… 2019-12-31 23:12:13 rstatstweet "My … rstat…
10 101181… 12121494… 2019-12-31 23:12:13 rstatstweet "My … rstat…
# … with 90 more rows, and 84 more variables: display_text_width <dbl>, ...
```


こんな感じで取得できました。100件なので指定した期間（2019年）で満遍なく取れるわけではなく、期間の中での最新の100件になるようです。

また、Premiumでは、ツイートにかけられるフィルタリングに制限がかかっています（例：リツイートを除けない）。
検索したいワードによってはリツイート数が大変なことになったりします。その辺どうにかしたければEnterpriseにするしかないのでしょうね...。


#### 注意！！！
__Windows R 64bit__ において、上記のコマンドが動かないエラーが見つかっています。なぜか同じコードはRstudio in Windowsでは動くようです。



取得したツイートをどういじっていくかについては別のtipsとして投稿できればと思っています。


Enjoy!
