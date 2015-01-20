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

`bin/rake spec:models`でテストを実行し、その時に出力された`log/test.log`から何が起きたかを見てみることにします。

### ソース

miyohide/db_cleaner_test@5ab96eede0f241255560e3baafbbb38786d168c6 のソースにて実行しました。

具体的には、動かしたテストは次のとおりです。

```ruby
require 'rails_helper'

RSpec.describe User, :type => :model do
  describe 'sample test1' do
    before do
      @user = FactoryGirl.create(:user)
    end

    it 'username and email' do
      expect(@user.user_name).to eq('user1 name')
      expect(@user.email_address).to eq('user1@example.com')
    end
  end

end
```

### 結果

動かしたときの`log/test.log`は次のようになりました。

```
  ActiveRecord::SchemaMigration Load (0.1ms)  SELECT "schema_migrations".* FROM "schema_migrations"
   (0.1ms)  begin transaction
   (0.0ms)  SAVEPOINT active_record_1
  SQL (0.4ms)  INSERT INTO "users" ("created_at", "email_address", "updated_at", "user_name") VALUES (?, ?, ?, ?)  [["created_at", "2015-01-15 13:23:05.257139"], ["email_address", "user1@example.com"], ["updated_at", "2015-01-15 13:23:05.257139"], ["user_name", "user1 name"]]
   (0.0ms)  RELEASE SAVEPOINT active_record_1
   (1.4ms)  rollback transaction
```

## 考察

`begin transaction`と`SAVEPOINT active_record_1`が出力されたあと、`users`テーブルにInsertしていることが分かります。その後、`rollback transaction`でInsertした`users`テーブルをロールバックし、Insertした結果をなかったコトにしています。

ま、ここでは、`SAVEPOINT`って機能を使って変更した内容を保存しては元に戻すってことをやっています。

# database_cleanerを使った場合

## サンプル1
### セットアップ

`database_cleaner`Gemのセットアップを行います。設定は、`database_cleaner`のREADMEから拾って、次のようにしました。

```ruby
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
```

また、[RSpecのマニュアル](https://relishapp.com/rspec/rspec-rails/docs/transactions)を見ると、`use_transactional_fixtures`を`false`にするってなことが書かれていたので、それを設定しました。

```ruby
  config.use_transactional_fixtures = false
```

### ソース

miyohide/db_cleaner_test@f32fa06d1b2a5e18fbd5df76b447cfbf15beb30a のソースにて実行しました。

具体的には、これまで動かしたコードと同じテスト次のコードです。

```ruby
require 'rails_helper'

RSpec.describe User, :type => :model do
  describe 'sample test1' do
    before do
      @user = FactoryGirl.create(:user)
    end

    it 'username and email' do
      expect(@user.user_name).to eq('user1 name')
      expect(@user.email_address).to eq('user1@example.com')
    end
  end

end
```

### 結果

動かしたときの`log/test.log`は次のようになりました。

```
  ActiveRecord::SchemaMigration Load (0.1ms)  SELECT "schema_migrations".* FROM "schema_migrations"
   (3.2ms)  DELETE FROM "users";
   (0.1ms)  SELECT name FROM sqlite_master WHERE type='table' AND name='sqlite_sequence';
   (0.1ms)  DELETE FROM sqlite_sequence where name = 'users';
   (0.0ms)  begin transaction
   (0.0ms)  commit transaction
   (0.0ms)  begin transaction
   (0.0ms)  SAVEPOINT active_record_1
  SQL (0.3ms)  INSERT INTO "users" ("created_at", "email_address", "updated_at", "user_name") VALUES (?, ?, ?, ?)  [["created_at", "2015-01-17 08:12:54.981577"], ["email_address", "user1@example.com"], ["updated_at", "2015-01-17 08:12:54.981577"], ["user_name", "user1 name"]]
   (0.0ms)  RELEASE SAVEPOINT active_record_1
   (0.8ms)  rollback transaction
```

### 考察

テストの開始直後に`DELETE FROM "users";`で`users`テーブルの中身をすべて削除しています。これは`database_cleaner`の`clean_with`メソッドによって指定した内容が実行されているためです。ここで`truncation`を指定していると、DELETE文によってデータベースの中身が全て削除されます。

合わせて、`sqlite_sequence`も削除しています。これはSQLite3での`id`値を保存しているテーブルで、これを初期化しています。

## 2つのテーブルの場合

先ほどのテストでは、`users`テーブルの中身が全部消えましたが、テーブルが2つある場合はどうなるでしょうか。scaffoldでもう一つテーブルを作って、テストを実行してみましょう。

### ソース

miyohide/db_cleaner_test@ のソースにて実行しました。scaffoldで`Post`モデルなどを生成して、簡単にfactoryとmodel specを作って、流してみました。

```ruby
require 'rails_helper'

RSpec.describe Post, :type => :model do
  describe 'sample test1' do
    before do
      @post = FactoryGirl.create(:post)
    end

    it 'title and body' do
      expect(@post.title).to eq('title1')
      expect(@post.body).to eq('body1')
    end
  end
end
```

### 結果

動かした時の`log/test.log`は次のようになりました。

```
  ActiveRecord::SchemaMigration Load (0.1ms)  SELECT "schema_migrations".* FROM "schema_migrations"
   (2.4ms)  DELETE FROM "users";
   (0.1ms)  SELECT name FROM sqlite_master WHERE type='table' AND name='sqlite_sequence';
   (0.1ms)  DELETE FROM sqlite_sequence where name = 'users';
   (1.6ms)  DELETE FROM "posts";
   (0.1ms)  SELECT name FROM sqlite_master WHERE type='table' AND name='sqlite_sequence';
   (0.1ms)  DELETE FROM sqlite_sequence where name = 'posts';
   (0.0ms)  begin transaction
   (0.0ms)  commit transaction
   (0.0ms)  begin transaction
   (0.0ms)  SAVEPOINT active_record_1
  SQL (0.3ms)  INSERT INTO "posts" ("body", "created_at", "title", "updated_at") VALUES (?, ?, ?, ?)  [["body", "body1"], ["created_at", "2015-01-20 12:13:02.313429"], ["title", "title1"], ["updated_at", "2015-01-20 12:13:02.313429"]]
   (0.0ms)  RELEASE SAVEPOINT active_record_1
   (0.7ms)  rollback transaction
   (0.0ms)  begin transaction
   (0.0ms)  commit transaction
   (0.0ms)  begin transaction
   (0.0ms)  SAVEPOINT active_record_1
  SQL (0.2ms)  INSERT INTO "users" ("created_at", "email_address", "updated_at", "user_name") VALUES (?, ?, ?, ?)  [["created_at", "2015-01-20 12:13:02.325174"], ["email_address", "user1@example.com"], ["updated_at", "2015-01-20 12:13:02.325174"], ["user_name", "user1 name"]]
   (0.1ms)  RELEASE SAVEPOINT active_record_1
   (0.8ms)  rollback transaction
```



