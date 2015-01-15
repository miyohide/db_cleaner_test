# これは何か

database_cleanerというgemがありますが、これがどのような設定をすればどのような動きをするのかがいまいち分からなかったのでサンプルアプリを書いてみました。これは、そのサンプルアプリと実行結果のまとめです。

# 前提条件

前提条件として次のバージョンでテストしました。

- Ruby 2.1.5
- Rails 4.1.8
- database_cleaner 1.4.0
- rspec-core 3.1.7
- SQLite3

# はじめに、database_cleanerを使わない場合

そもそも、database_cleanerを使うと何が嬉しくて、何が嬉しくないのかをはっきりさせるために、まずはdatabase_cleanerを使わない例を試します。

## 実行

`bin/rake rspec:models`でテストを実行し、その時に出力された`log/test.log`から何が起きたかを見てみることにします。


