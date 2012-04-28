require 'spec/helper'
describe RelationshipsController do
  let(:user) {FactoryGirl.create(:user)}
  let(:other_user) {FactoryGirl.create(:user)}
  before {sign_in user}
  
  describe "should create Ajax relationships" do
    
    it "should increment Relationships count" do
      expect do
        xhr :post, :create, :relationship => {:followed_id => other_user.id}
      end.should change(Relationship, :count).by(1)
    end
    
    it "should be success" do
      expect do
        xhr :post, :create, :relationship => {:followed_id => other_user.id}
        response.should be_success
      end
    end
  end
  
  describe "destroying relationships with Ajax" do
    before {user.follow!(other_user)}
    let(:relationship) {user.relationships.find_by_followed_id(other_user)}
    
    it "should decrement relationships count" do
      expect do
        xhr :delete, :destroy, :id => relationship.id
      end.should change(Relationship, :count).by(-1)
    end
    
    it "shoudl be success" do
      expect do
        xhr :delete, :destroy, :id => relationship.id
      end.should be_success
    end
  end
end
