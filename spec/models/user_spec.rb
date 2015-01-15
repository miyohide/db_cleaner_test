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
