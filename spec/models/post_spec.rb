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
