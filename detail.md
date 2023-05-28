---
---

<h3>評価に関する詳細</h3>

　[開発言語の選定]({{site.baseurl}}/select_lang)では星取表を使って開発言語の選定を行った。ここでは星取表で使用した星の選定根拠について言及する。

　個々の言語に関する言及をする前に判断基準について再度記述する。条件は短縮表記にしている。条件の内容を確認したい場合は[開発言語の選定]({{site.baseurl}}/select_lang)で確認できます。

|短縮表記　　|判断基準|
|-|-|
|初心者|習得難易度が低いこと。（構文が単純、可読性が高いなど）|
|調べやすさ|信頼度の高い一次情報にアクセスしやすいこと。学習のための本が多く出版されていること。日本語でアクセスできれば更によいとする。|
|短期開発|定番のwebアプリケーションフレームワークの有無|
|個人開発|言語の得意な用途が、小規模・個人開発に向いているか？|
|OOP|サポートしているか否か。|

　上記の表の項目に対して、それぞれの評価について言及する。評価に関して可能な限りN君の主観が入らないように努めたが、多少の主観は入ってしまっている。しかし本件はあくまでN君一人で開発を行うためその点は問題にしないこととする。

　また、個人開発の項目は判断が難しい。今回は調べた全体としての傾向として判断する。

### Ruby (合計11点)
---
#### 1.初心者       ◯(2点)
　Rubyはプログラムがわかりやすい。こういった文言はWeb上で調べればいくらでも出てくるほど有名であると思う。その要因としてRubyがスクリプト言語であることが考えられる。  
そのため初心者から人気な言語の一つであると言えると考えた。しかし他にも初心者向きの言語は存在するため良いという意味で、◯(2点)とした。

　また、本件では特に断りがない限りスクリプト言語は構文が簡単であり、可読性が高く、プログラムを作成しやすい点から基本的に◯(2点)とする。

#### 2.調べやすさ   ◎(3点)
　Rubyはまつもとゆきひろ氏が作成したプログラム言語として知られている。そのため国産のプログラム言語であり、その影響か公式ドキュメントが日本語で提供されている（もちろん英語のドキュメントも存在する）。多くの言語の公式ドキュメントは翻訳された日本語として提供されている。プログラミングになれた人が英語のドキュメントや翻訳されたドキュメントを読むことは造作もないことであると推測される。しかしN君は初心者であるため可能な限り日本語で学習できる環境を整えたい。  
　また、Rubyは初心者に人気の言語である影響か数多くの本も出版されている。N君が参考にしている[プロを目指す人のためのRuby入門](https://gihyo.jp/book/2017/978-4-7741-9397-7)（通称チェリー本）など数多くの本が出版されている。  
　以上の理由から、日本語の公式ドキュメント（非翻訳）が存在する、学習のための本が多く出版されている、これらの点を評価し◎(3点)の非常に良いという判断をした。

#### 3.短期開発     ◯(2点)
　Rubyの定番アプリケーションといえばRuby on Railsだと思われる。その証拠として[オブジェクト指向でなぜつくるのか](https://bookplus.nikkei.com/atcl/catalog/21/S00180/)という本のコラムとして「RailsフレームワークでブレークしたRuby」があるほどである。そのため定番フレームワークの有無として評価するため◯(2点)として評価した。

　◎(3点)でない理由としては定番フレームワークがN君がわかる範囲で他のフレームワーク（他言語のフレームワーク、LaravelやDjangoなど）と一線を画すほど優れていると判断できなかったからである。

#### 4.個人開発     ◯(2点)
　用途については少し難しく、Webで調べた全体的な印象として評価したい。まずRuby本体のWeb全体の印象としては少し人気が落ちてきていると感じた。その一方で得意というよりは傾向としてスタートアップ企業やベンチャー企業が選択する言語としてRubyが多いという印象を受けた。（全体の印象もあるが、はっきり明言している解説動画やWebサイトもあった。）  
　そのためスタートアップ企業で選択されているほどなので、小規模開発に向いていると判断し◯(2点)とした。

#### 5.OOP          ◯(2点)
　Rubyはオブジェクト指向プログラミングをサポートしている。そのため◯(2点)の評価を行った。

### PHP (合計9点)
---
#### 1.初心者       ◯(2点)
　PHPはスクリプト言語である。そのため上記の通り基本的に◯(2点)として評価する。

#### 2.調べやすさ   ◯(2点)
　PHPの公式ドキュメントは翻訳された日本語として提供されている。また、書籍に関してもRubyと同様に多く出版されており学習しやすい環境は整っている。そのため◯(2点)として評価した。

#### 3.短期開発     ◯(2点)
　PHPの定番フレームワークといえばLaravelだと考えられる。実際、
[PHPフレームワーク Laravel入門](https://www.shuwasystem.co.jp/book/9784798060996.html)では、以下のように評価されている。
> 「PHPフレームワークのデファクトスタンダード」の地位を確立した

そのため◯(2点)という評価をした。

#### 4.個人開発     △(1点)
　PHPの特徴はなんといってもシェアの大きさだと思う。[W3Techs](https://w3techs.com/)によればサーバサイド言語のシェアは77.4%もあり驚異的な数値を保有している。この数の要因としては2つ考えられる。1つはWordPressというCMSで使われていること、2つ目はWeb業界で長く使われていることが要因であると考えられる。  
　1つ目に関して、[W3Techs](https://w3techs.com/)や[WordPress.com](https://wordpress.com/ja/)でも書かれている通り、WordPressはWebの約43%で使用されている。そしてWordPressで使うのはPHPである。すべてのサイトでCMSを使用しているわけではないがPHPの利用率が高い要因の一つであること言えると考えられる。  
　2つ目に関して、歴史が長いことについては[PHPの歴史](https://www.php.net/manual/ja/history.php.php)で示されている。このサイトによればPHPは1994年に誕生している、そして誕生当時からWebで利用されるものとして作られている（CGIバイナリ群として作成されているためこのように判断した）。[プロになるためのWeb技術入門](https://gihyo.jp/book/2010/978-4-7741-4235-7)によれば、WWWが提案されたのが1989年である。そのため、その5年後にPHPが誕生したと考えれば歴史が長く、それ故に不具合が少なく信頼性の高い言語であると考えられる。

　上記のことからPHPが得意とするのはCMSとしてWordPressを使う場合や、信頼性の高いサイトを作りたいといった場合である。そのため主な用途としてはブログやECサイトなどの大規模サイトであると考えられる。信頼性が高い故に大規模なサイトにも対応可能であるというのはPHPの魅力だと考えられる。

　しかし、現在N君は個人で小規模な開発を行おうとしている。大規模なサイトを使う場合PHPを選択することはよいことであるが、そうでない場合PHP意外の選択しも十分に考えられる。小規模開発での利用と考えれば選択肢としてはあまり良くないため△(1点)と判断した。

#### 5.OOP          ◯(2点)
　PHPはオブジェクト指向プログラミングをサポートしている。そのため◯(2点)として評価した。

### Python (合計9点)
---
#### 1.初心者       ◯(2点)
　Pythonはスクリプト言語である。故に◯(2点)として評価した。

#### 2.調べやすさ   ◯(2点)
　Pythonの公式ドキュメントは翻訳された日本語として提供されている。書籍に関しても他の言語と同様に多くの書籍が出版されており学習しやすい環境が整っている。そのため◯(2点)として評価した。

#### 3.短期開発     ◯(2点)
　[Python Developers Survey 2021 Results](https://lp.jetbrains.com/python-developers-survey-2021/)でPythonで使用するフレームワークについて言及されている。これによればFlask、Django、FastAPIの3つのフレームワークの使用率が非常に高いことがわかる。また、本に関してもDjangoに関する本を多く目にした。そのためPythonにおいては定番フレームワークとしてはFlask、Django、FastAPIの3つが存在すると言える。  
　上記の理由のため◯(2点)と評価した。

#### 4.個人開発     △(1点)
　Pythonを使っている最も有名なサイトはおそらくYouTubeであると考えられる。YouTubeは大規模なサイトである。また、Pythonの魅力としてライブラリが豊富、とりわけ機械学習やディープラーニングなどのライブラリが豊富である。そのため人工知能を利用したサイトなどが得意であると予想される。
　N君はいま個人の小規模開発をするため大規模サイトに強い言語を選ぶことは良いとは言えない。また、AIを使った機能を作り込む予定はないため、Pythonを選択するのは良いとは言えないだろう。そのため△(1点)と評価した。

#### 5.OOP          ◯(2点)
　Pythonはオブジェクト指向プログラミングをサポートしている。そのため◯(2点)と評価した。

### Java  (合計8点)
---
#### 1.初心者       △(1点)
　Javaはコンパイルして実行する、コンパイラ型のプログラム言語である。そのため上記までのプログラム言語に比べて構文が複雑になっている。また同じ実行内容を実現するために必要なコードの量も他言語に比べ多い。そのため初心者向きかどうか考えた場合、他の言語に比べ学習難易度が高いことが考えられる。そのため評価としては△の1点として評価した。  
（Javaが初心者向きでないと言っているわけではない。他の言語と比べた場合、初心者に易しい言語が他にあるというだけである）

#### 2.調べやすさ   ◯(2点)
　Javaの言語リファレンスは翻訳されたものがある。以下にリンクを示す。
- [Java ® Platform, Standard Edition & Java Development Kit
バージョン18 API仕様](https://docs.oracle.com/javase/jp/18/docs/api/index.html)

　また、Javaについても学習のための本は数多く出版されている。そのため調べやすさは◯の2点として評価した。

#### 3.短期開発     ◯(2点)
　Javaの定番フレームワークとしては以下のPDFが参考になると考えられる。
- [Java開発者への 過去最大の調査 - Oracle](https://www.oracle.com/webfolder/technetwork/jp/javamagazine/Java-ND18-Survey-ja.pdf)

　このPDFの13ページ（右下のページ数で17ページ）の、「使っているWebフレームワークはどれですか。」にフレームワークの使用率について言及されている。これによれば以下のフレームワークが非常によく使われていると言えるだろう。

1. Spring Boot
1. Spring MVC

上記のフレームワークについて調べたところどちらもSpring Frameworkに関係するものであり、Javaの定番のWebフレームワークと聞かれればSpring Frameworkと答えても差し支えはないと考えられる。  
　そのため定番フレームワークの有無という判断基準ではJavaでは有りとなるため、評価としては◯の2点として評価した。

#### 4.個人開発     △(1点)
　Javaの得意な用途として挙げられるのは大規模で安定した動作が要求されるシステムだと考えられる。例をあげるなら官庁などで利用されるシステムだろう。  
　その根拠は、Javaの歴史は非常に長く信頼性の高い言語であることだ。Javaの誕生については以下の記事に示されている。

> - [「Javaはオラクルのもの？」、「いいえ、これからもJavaコミュニティのものです！」――Javaエバンジェリスト 寺田佳央氏が、Javaの現在、未来を語る](https://www.oracle.com/jp/technical-resources/article/pickup/java-evangelist-kao-terada.html)  
このサイトによればJavaの誕生は1995年。PHP誕生の翌年には存在していたことになる。

　歴史の長い言語はバグが少なく安定して動作できるため、システムの大規模化に対応することができる。しかし、大規模なシステムが得意な言語を本件で選択することは良い選択とは言えない。そのため評価は△の1点として評価を行った。

#### 5.OOP          ◯(2点)
　Javaはオブジェクト指向プログラミングをサポートしている。そのため2点として評価した。

### Go (合計6点)
---
#### 1.初心者       ◯(2点)
　Goは比較的新しい言語であり、Goを表す特徴は公式ドキュメントの文章が参考になると考えられる。以下にリンクと説明文の一部（日本語訳を鉤括弧で表記）を示す。

> - [Documentation](https://go.dev/doc/)  
このサイトはじめの文章の後半にGoの特徴がよく現れていると感じた。日本語にするとおおよそ以下のとおりである。  
「Goは高速で静的型付けされたコンパイル言語でありながら、動的型付けされたインタプリンタ言語のような感覚で使用できる」

　故にGoはコンパイル型言語とスクリプト型言語との中間的な特徴を持っていると言えるだろう。そのため構文は単純であり初心者にとっては良いと考えられる。反面、C言語的な要素が存在し習得が難しい可能性があるが、他の言語もオブジェクト指向の概念があり習得が簡単と一概に言えないため、この点でマイナスの評価を行う必要はないと考えられる。  
　そのため、構文が比較的単純で習得しやすい点から◯の2点として評価した。

#### 2.調べやすさ   ◯(2点)
　Goには公式の英語で書かれた言語仕様書([The Go Programming Language Specification](https://go.dev/ref/spec))がWeb上に公開されている。また、有志による日本語化([Go プログラミング言語仕様](https://hiwane.github.io/gospec-ja/))も進められている。  
　また、Goに関しても書籍は多く出版されている。  
　そのため調べやすい環境は整っていると考えられるため、評価は◯の2点として評価した。

#### 3.短期開発     △(1点)
　Goの定番のWebフレームワークについては以下のサイトが参考になると考えられる。
1. [【最新2022】バックエンドおすすめ言語：結論→Java・Ruby・Go](https://tech-parrot.com/programming/recommended-backend-language-for-web-engineers/)
1. [社畜エンジニアがおすすめする2022年トレンドのGoフレームワークまとめ](https://wiblok.com/go/go_framework_2022/)
1. [Go言語のフレームワークはこの5つを押さえよう【2022年版】](https://tech-reach.jp/column/402/)

　Goのwebフレームワークに関しては調査が非常に難しい。上記サイトではそれぞれ異なることを主張している。1つ目はフレームワークは使用せずに開発するのが一般的だと主張し、2つ目はGinがデファクトスタンダードであると主張、3つ目はデファクトスタンダードは登場していないと主張している。  
　この件についてはある程度N君の主観で判断する必要があると考えた。これまでの言語では定番のフレームワークには書籍が存在した。そのためGinについても書籍があるか調べることにした。その結果、少なくとも開発計画時（調査時は2022/11頃で存在していない）には日本語で書かれた書籍は存在しない可能性が高いことがわかった（英語では一冊ほどありそうだった）。そのため少なくとも日本ではGinはデファクトスタンダードであるとは言いにくいと考え、Goにおける定番フレームワークは存在しないと判断した。そのため△の1点とした。✕の0点としなかった点はWebフレームワークが存在しないわけではないからである。

#### 4.個人開発     △(1点)
　Goでの主な用途はマイクロサービスであると感じた。もちろんGoにもフルスタックのフレームワークは存在するためWebサービス全体を構築することは可能である。しかし、デファクトと呼ばれることもある[Gin](https://gin-gonic.com/ja/)に参考書が存在しない点からそれらのフレームワークはN君にはハードルが高いと考えられるため選択肢としては不適切である。  
　またGoの採用実績について言及しているサイトの例を以下に示す。
- [Go言語でできることとは？Go言語で作れるアプリの事例を紹介](https://www.ownly.jp/programmingschool/use-of-go/)

　上記のサイトによれば、Webサービスの一部にGoを使っているということらしい。そのため、少なくとも初心者のN君がはじめて取り組むにはGoは難しい。Go自体は小規模な開発で確かに利用されるが（マイクロサービスなので）、あまりに機能が限定的すぎるため本件では適切でないと考えた。そのため評価は△の1点とした。

#### 5.OOP          ✕(0点)
　Goはオブジェクト指向プログラミングをサポートしていると言えないと感じた。Go言語にはオブジェクト指向言語にある機能が存在することは事実である。しかし一般的なオブジェクト指向言語(c++やc#、Rubyなど)とは異なる点が多いと感じた。ただし、できないわけではない。問題はGo独特の方法で実現しなければいけないということだと感じた。  
　オブジェクト指向言語を評価項目とした理由は、多くの言語がオブジェクト指向プログラミングをサポートしているが、N君にはその経験が少なかったからである。そのためGo独特のオブジェクト指向を学ぶより多くの言語に共通する概念を理解するためにはGoは不適切であると判断した。そのため、オブジェクト指向を学習するという主旨に反するという点、オブジェクト指向プログラミングをサポートしているとは言えない点から✕の0点として評価した。

注釈）  
他の言語にもそれぞれオブジェクト指向の内容が違うことはある。例えばRubyでは抽象クラスや抽象メソッドが存在しない。しかしその点以外はほとんど問題がないように見える（N君はc++、c#でオブジェクト指向を使った経験がある。この経験から判断した）。  
　Goの場合、まずclassが定義できず構造体になるそうだ。この点からまず特殊だと言えるだろう（どちらかといえばCに近い）。しかし悪い点ばかりではない。Goはこれまでのオブジェクト指向プログラミングの問題点を解決しようと試みた結果、特殊な書き方になったそうだ（様々なサイトを見た傾向的にそう感じた）。そのためその特異さが悪いわけではない。ただオブジェクト指向言語を学ぶという点で目的と一致しないだけである。言語単体で見れば非常に強力で魅力的な言語であることに間違いはないと考えられる。

### 評価に関する総括
---
　評価の詳細は以上である。可能な限り信頼性の高い情報に触れたり、様々なサイトと見比べて判断したり、本を読んだりして正しい判断をしようと試みたつもりである。しかし一人で判断するにはある程度限界があると感じた。とりわけGoについては非常に判断が難しいと感じた。Ginは非常に強力なフレームワークである反面、非常に自由度が高いものであると感じる。なぜならフレームワークはディレクトリ構造ごとプロジェクトを作成するがGinはディレクトリ構造を指定しない（調べた限り特に出てこない）。自由度が高いことは良いことであるが、それは知識のある人という前提が隠れている。知識がなければどのようにファイルを配置すべきか？どういったディレクトリ構造を構築すればいいか？判断することができないからだ。本来小規模な開発に利用されるGoは個人開発の星は◯の2点とするべきである。しかし、N君が初心者で自由度が高すぎるフレームワークを扱うには知識が足りないということもあり評価を低く設定するべきだと考えた。この評価方法は、はじめに明言した個人開発に向いているかではなく初心者向きでないという点が混同するため明言せずに、別の要因で評価をした。できるだけ各項目が干渉しないようにも努めたがどうしても干渉してしまった。次に星取表を作るときはよりいっそう考慮すべきだと感じた。

　しかし冒頭で言及したとおり、あくまで開発するのはN君一人であるため偏りが生じるのはある程度許容することとし、それ以上に効率よく開発することを目指し活動を行うことを目指す。  
　