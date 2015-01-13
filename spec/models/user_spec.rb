require 'rails_helper'

RSpec.describe User, :type => :model do
  describe 'test1' do
    before do
      @user = FactoryGirl.create(:user)
    end

    it 'username' do
      expect(@user.user_name).to eq('user1 name')
      expect(@user.email_address).to eq('user1@example.com')
    end

    it 'email' do
      user = FactoryGirl.create(:user2)
      expect(user.user_name).to eq('user2 name')
      expect(user.email_address).to eq('user2@example.com')
    end
  end

end
