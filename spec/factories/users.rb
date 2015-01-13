FactoryGirl.define do
  factory :user do
    user_name     "user1 name"
    email_address "user1@example.com"
  end

  factory :user2, class: User do
    user_name     "user2 name"
    email_address "user2@example.com"
  end
end
