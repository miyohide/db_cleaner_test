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

5ab96ee のソースにて実行しました。

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





