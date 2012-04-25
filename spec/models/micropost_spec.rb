require 'spec_helper'

describe Micropost do
  let(:user){FactoryGirl.create(:user)}
  before{ @micropost=user.microposts.build(:content => 'Lorem Ipsum') }
  subject{ @micropost }
  
  it{should respond_to(:content)}
  it{should respond_to(:user_id)}
  it{should respond_to(:user)}
    
  its(:user){should==user}
  it{should be_valid}
  
  describe "when user id is not present" do
    before{@micropost.user_id=nil}
    it{should_not be_valid}
  end
  
  describe "when content is blank" do
    before{@micropost.content=''}
    it{should_not be_valid}
  end
  
  describe "content should not be long" do
    before{@micropost.content='a'*141}
    it{should_not be_valid}
  end
  
  describe "accessible attributes" do
    it "should not allow access to user id" do
      expect do
        Micropost.new(:user_id => user.id)
      end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end
  
  describe "micropost associations" do
    before{@user.save}
    let!(:older_micropost) do
      FactoryGirl.create(:micropost, :user => @user, :created_at => 1.day.ago)
    end
    let!(:newer_micropost) do
      FactoryGirl.create(:micropost, :user => @user, :created_at => 1.hour.ago)
    end
   
    it "should have the right microposts in the right order" do
      @user.microposts.should==[newer_micropost,older_micropost]
    end
    it "should delete associated microposts" do
      microposts=@user.micropost
      @user.destroy
      microposts.each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end
  end
  
end
