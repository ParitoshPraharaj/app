# == Schema Information
#
# Table name: users
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  password_digest :string(255)
#

require 'spec_helper'

describe User do
 before do
     @user= User.new(:name => "Michael Hartl", :email => "michael@example.com", :password => "business", :password_confirmation => "business") 
 end   
 subject { @user }
 
 it {should respond_to(:name)}
 it {should respond_to(:email)}
 it {should respond_to(:password_digest)}
 it {should respond_to(:password)}
 it {should respond_to(:password_confirmation)}
 it {should respond_to(:admin)}
 it {should respond_to(:microposts)}
 it {should respond_to(:feed)}
 it {should respond_to(:authenticate)}
 it {should respond__to(:relationships)}
 it {should respond_to(:followed_users)}
 it {should respond_to(:reverse_relationships)}
 it {should respond_to(:followers)}
 it {should respond_to(:following?)}
 it {should respond_to(:follow!)}
 it {should respond_to(:unfollow!)}
 
 it {should be_valid} #Checks whether the user object is present
 it {should_not be_admin}
 
 describe "when name is not present" do
   before { @user.name='' }
   it {should_not be_valid}
 end
 
 describe "when email is not present" do
   before { @user.email='' }
   it {should_not be_valid}
 end
 
 describe "when name is too long" do
   long='a'*51
   before { @user.name=long }
   it { should_not be_valid }
 end
 
 describe "when email format is invalid" do
   it "should be invalid" do
     addresses=%w[user@example,com user_first_last.example.com first@last.cn.]
     addresses.each do |invalid_address|
       @user.email=invalid_address
       @user.should_not be_valid
     end
   end
 end
 
 describe "when email format is valid" do
   it "should be valid" do
     addresses=%w[user@example.com FIRST_LAST@example.com a+b@example.cn user_first_last@example.au]
     addresses.each do |valid_address|
       @user.email=valid_address
       @user.should be_valid
     end
   end
 end
 
 describe "when email address is already taken" do
   before do
     user_with_same_email=@user.dup
     user_with_same_email.email=@user.email.upcase
     user_with_same_email.save
   end
   it {should_not be_valid}
 end
 
 describe "when passwords do not match" do
   before {@user.password=@user.password_confirmation=''}
   it {should_not be_valid}
 end
 
 describe "when passwords do not confirm " do
   before{@user.password_confirmation="mismatch"}
   it {should_not be_valid}
 end
 
 describe "when password confirmation is nil" do
   before{@user.password_confirmation=nil}
   it {should_not be_valid}
 end
 
 describe "response to authenticate" do
   before{ @user.save }
   let(:found_user) { User.find_by_email(@user.email) }
   
   describe "when passwords match" do
     it{should == found_user.authenticate(@user.password)}
   end
   
   describe "when passwords do not match" do
     let(:invalid_user_found) { found_user.authenticate("invalid") }
     
     it {should_not==invalid_user_found}
     specify { invalid_user_found.should be_false }
   end
 end
 
 describe "when passwords are too short" do
   before{ @user.password=@user.password_confirmation='a'*5 }
   it{ should be_invalid }
 end
 
 describe "remember token" do
   before {@user.save }
   its(:remember_token){should_not be_blank}
 end
 
 describe "when admin attribute is set to 'true' " do
   before{@user.toggle!(:admin)}
   it{ should be_admin }
 end
 
 describe "micropost associations" do
   before {@user.save}
   let!(:older_micropost) do
     FactoryGirl.create(:micropost, :user => @user, :created_at => 1.day.ago)
   end
   
   let!(:newer_micropost) do
     FactoryGirl.create(:micropost, :user => @user, :created_at => 1.hour.ago)
   end
   
   describe "status" do
     let!(:unfollowed_post) do
       FactoryGirl.create(:micropost, :user => FactoryGirl.create(:user))
     end
     let(:followed_user) {FactoryGirl.create(:user)}
     
     before do
       @user.follow!(followed_user)
       3.times {followed_user.microposts.create!(:content => 'Lorem ipsum')}
     end
     
     its(:feed) {should include(older_micropost)}
     its(:feed) {should include(newer_micropost)}
     its(:feed) {should_not include(unfollowed_post)}
     its(:feed) do
       followed_user.microposts.each do |micropost|
         should include(micropost)
       end
     end
   end
 end
 describe "following" do
   let(:other_user) {FactoryGirl.create(:user)}
   before do
     @user.save
     @user.follow!(other_user)
   end
   
   it {should be_following(other_user)}
   its(:followed_users) {should include(other_user)}
   
   describe "followed user" do
     subject { other_user }
     its(:followers) {should include(@user)}
   end
   describe "and unfollowing" do
     before { @user.unfollow!(other_user) }
     it{should_not be_following(other_user)}
     its(:followed_users) {should_not include(other_user)}
   end
 end 
 
end
