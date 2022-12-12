---
---

<h3>UML及びER図の書き方</h3>
　UMLおよびER図の書き方について言及する。不要かと思われるがPlantUMLの仕様と本などで書かれている仕様が若干違うためここで明言する。

#### 1.ER図
　PlantUMLではER図は以下のように書く。
- [ER図](https://plantuml.com/ja/ie-diagram)  

上記の例に従い、本件では以下のように各属性を表記する。

|![エンティティの属性の書き方についての画像]({{site.baseurl}}/assets/images/entity-description.png)|
|:-:|
|図1　エンティティの属性の書き方|

また、多重度の記法についてはIE記法を用いる(PlantUMLでもサポートされているため)。以下のサイトが非常にわかりやすく説明されていた。以下を参考とする。
1. [【IE記法】ER図の書き方](https://qiita.com/djkazunoko/items/207b4fac8adeae3085f1)
1. [ER 図の Crow's Foot 記法 (IE 記法)](https://knooto.info/erd-crows-foot/)

多重度の意味についてはPlantUMLのマニュアルに記載されているためそちらで確認できる。
- [ER図](https://plantuml.com/ja/ie-diagram) 

上記を参考に、本件でのER図の書き方について定める。正規化の段階によって属性の書き方は変わると考えられるが以下の点は共通するとしER図を作成する。

1. エンティティ名（=テーブル名）は上段に`E`の横に記す。
1. 中段の`Primary Key`のブロックは主キー属性を表す。
1. 下段の`Columns`のブロックはその他の外部キーや非キー属性を表す。
1. 外部キーは`(FK)`をつけて表す。

本件ではエンティティ名をRDBMS上のテーブル名として使用する。