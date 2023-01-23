---
---

<h3>追加の設定</h3>
　先日、redisについて簡単に学習した。そのため開発環境にもredisの設定を追加する。以下の設定を追加する。

```yml
#cable.yml
development:
  adapter: redis
  url: redis://172.19.0.3:6379
```

設定方法は以下を参考にした。
- [Action Cable Overview — Ruby on Rails Guides](https://edgeguides.rubyonrails.org/action_cable_overview.html#redis-adapter)

また、redisコンテナも起動できるように設定を変更する。設定方法は先日学習した内容を元に記述する。
- [GitHub - Nagasaka-Hiroki/redis_sample_1: redisについて学習する。](https://github.com/Nagasaka-Hiroki/redis_sample_1)

これらの設定を加えてバージョンを`v0.1.1`としてプッシュする。