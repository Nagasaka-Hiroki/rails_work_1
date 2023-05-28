---
---

<h3>前提条件</h3>
　開発を行う前に前提条件について整理する。

　[開発シナリオ]({{site.baseurl}}/dev_scenario)で述べた通り、本件は<u>初心者が一人で開発を行う</u>ことを前提としている。また、あくまで技術習得を目標としているため可能な限り短期間で開発を行うことにする。

　また、N君は初心者であるがFortranやC言語などの手続き型言語の経験がある。しかし、<span style="color: red;">オブジェクト指向言語の経験が少ない</span>。
プログラミング言語は大まかに分けて、手続き型言語、オブジェクト指向言語、関数型言語に分類される。
中でも現在の主流言語の多くはオブジェクト指向をサポートしているため<u>オブジェクト指向の習得は必須事項</u>であり、この技術の習得はN君にとって急務である。

　そのためN君の状況から以下の項目を重視して開発を行う。
1. 初心者に易しいこと
1. 調べやすい（Web上および書籍から情報を入手しやすい）こと
1. 効率的に成果物を作成できること（短期間で開発できること）
1. ある程度現場で広く使われていること
1. 小さいリソースでの開発に向いていること
1. オブジェクト指向プログラミングをサポートしていること

　またN君の状況以外に動作環境として以下の状況を想定する。

1. 開発コミュニティ内（プライベートネットワーク内）のみで使用するツールとして作成する。
1. 開発コミュニティの人全員がPCを所持しており、PCから利用することを前提とする。(スマートフォンでは利用しない)

そのためPCのブラウザからサーバにアクセスし利用できるサービスを作成する。ブラウザの選定は以下のサイトを参考に行う。
- [Browser Market Share Worldwide｜Statcounter Global Stats](https://gs.statcounter.com/browser-market-share)

このサイトは他のサイト（例：[世界のデスクトップブラウザ市場シェア2022 年版](https://kinsta.com/jp/browser-market-share/))でも使用されているためある程度信頼できると考えられる。

このサイトによれば、ブラウザのシェアの半数は<span style="color: red;">Chrome</span>である。また、ホストOSがLinuxの場合も考慮しFirefox上でも動作すると便利である。  
ゆえに、本件での対象のブラウザは以下のとおりである。
1. Chrome
1. Mozilla Firefox

しかし、N君は主に調べごとにChromeを使っている。ゆえに開発の途中で頻繁にブラウザを閉じることを考えて、開発時ではFirefoxを主に使用することにする。

以上を前提条件として開発を行っていく。