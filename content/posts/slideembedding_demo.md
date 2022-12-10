---
title: Slide Embedding Demo
date: 2022-07-13
tags: ["hugo", "git"]
---

# スライドを埋め込むデモ

github pages by hugoにスライドを埋め込む方法を調べたのでメモがてら。

Office 365とGoogle slidesを使った例を紹介。どちらもウェブ上でスライドをいじった後にブログの方をリロードすれば自動で更新がかかるので優秀。

### Office 365の機能を使った例
<div class="iframe-outer">
<iframe class="iframe-tags" src="https://o365tsukuba-my.sharepoint.com/personal/s2030225_u_tsukuba_ac_jp/_layouts/15/Doc.aspx?sourcedoc={1fb818fd-baa4-4cf9-a96f-acd8c2672ab5}&amp;action=embedview&amp;wdAr=1.7777777777777777" width="476px" height="288px" frameborder="0">This is an embedded <a target="_blank" href="https://office.com">Microsoft Office</a> presentation, powered by <a target="_blank" href="https://office.com/webapps">Office</a>.</iframe>
</div>

ログインしないと見れないのが難点かも...？
ログインせずに見れる方法があれば教えてください。

### Google slidesを使った例
<div class="iframe-outer">
<iframe class="iframe-tags" src="https://docs.google.com/presentation/d/e/2PACX-1vTdn0yrR3dS75dBUnqpzyhiGaJjtMwu3HTNK1IMSGDwN16hrKtCFnwc49JIiwogCFHy0tRxx4FwyjAx/embed?start=false&loop=false&delayms=3000" frameborder="0" width="960" height="569" allowfullscreen="true" mozallowfullscreen="true" webkitallowfullscreen="true"></iframe>
</div>

こっちのが良いかも。


### レスポンシブにするには
出てきたiframeタグに対してその上位にdivタグを設定。そこに対してclassやidでcssを直接あてに行く。

具体的には以下のような感じでできる。

```html
<div class="iframe-outer">
<iframe class="iframe-tags" src="...", ...</iframe>
</div>
```

```css
.iframe-outer{
  position: relative;
  padding-top: 75%; /* 4:3の縦横比率にしたい場合、3÷4=75% */
}

.iframe-tags{
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}
```




<!--
### PDFをそのまま呼びに行く
{%pdf https://github.com/6W3N/R4DS_EX/blob/master/3Ex/3-2-4Ex.pdf %}

### URLはこっちかも
{%pdf https://raw.githubusercontent.com/6W3N/R4DS_EX/ee5fdad72ceb2ca6c6f1873ed5f8f0091624632e/3Ex/3-2-4Ex.pdf %}
-->
