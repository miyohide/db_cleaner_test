require 'rails_helper'

RSpec.describe "users/index", :type => :view do
  before(:each) do
    assign(:users, [
      User.create!(
        :user_name => "User Name",
        :email_address => "Email Address"
      ),
      User.create!(
        :user_name => "User Name",
        :email_address => "Email Address"
      )
    ])
  end

  it "renders a list of users" do
    render
    assert_select "tr>td", :text => "User Name".to_s, :count => 2
    assert_select "tr>td", :text => "Email Address".to_s, :count => 2
  end
end
