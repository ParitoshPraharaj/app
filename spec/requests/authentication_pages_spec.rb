require 'spec_helper'

describe "AuthenticationPages" do
  
  subject{ page }
  
  describe "visit signin page" do
      before{ visit signin_path }
      it {should have_selector('h1', :text => "Sign In")}
      it  {should have_selector('title', :text => "Sign In")}
  end
  
  describe "sign in" do
    before{visit signin_path}
    
    describe "with invalid information" do
      before{click_button "Sign In"}
       it {should have_selector('h1', :text => "Sign In")}
       it {should have_selector('div.alert.alert-error', :text => "Invalid")}
       
       describe "after visiting another page" do
         before{click_link 'Home'}
         it{should_not have_selector('div.alert.alert-error')}
       end
    end
    
    describe "with valid information" do
      let(:user){FactoryGirl.create(:user)}
      before { sign_in user }
      describe "followed by signout link" do
        before{click_link "Sign Out"}
        it{should have_link("Sign In")}
      end
      it {should have_selector('title', :text => user.name)}
      it{should have_link('Users', :href => users_path)}
      it{should have_link('Profile', :href => user_path(user))}
      it{should have_link('Settings', :href => edit_user_path(user))}
      it{should have_link('Sign Out', :href => signout_path)}
      it{should_not have_link('Sign In', :href => signin_path)}
      
    end
  end
  
  describe "authorization" do
    
    describe "for non-signed in users" do
      let(:user){FactoryGirl.create(:user)}
      describe "while accessing a protected page" do
        before do
          fill_in "Email", :with => user.email
          fill_in "Password", :with => user.password
          click_button 'Sign In'
        end
        describe "after signing in" do
          it "should redirect to the protected page" do
            page.should have_selector('title', :text => 'Edit user')
          end
        end
        describe "when signing in again" do
          before do
            visit sign_in_path
            fill_in "Email", :with => user.email
            fill_in "Password", :with => user.password
            click_button 'Sign In'
          end
          it "should render the default profile page" do
            page.should have_selector('title', :text => user.name)
          end
          
        end
        describe "in the microposts controller" do
          describe "submitting to the create path" do
            before{post microposts_path}
            specify{response.should redirect_to(sign_in path)}
          end
          describe "submitting to the destroy path" do
            before do
              micropost=FactoryGirl.create(:micropost)
              delete micropost_path(micropost)  
            end
            specify{response.should redirect_to(sign_in path)}
          end
        end 
        describe "in the Relationships Controller" do
          describe "while submitting to the create action" do
            before {post relationships_path}
            specify {response.should redirect_to(signin_path)}
          end
          describe "while submitting to the delete action" do
            before {delete relationship_path(1)}
            specify {response.should redirect_to(signin_path)}
          end
        end
      end
    end
    
    describe "with non-signed in users" do
      let(:user){FactoryGirl.create(:user)}
      
      describe "in users controller" do
        
        describe "it should have the following link" do
          before {visit following_user_path(user)}
          it {should have_selector('title', :text => 'Sign In')}
        end
        
        describe "it should have the followers link" do
          before {visit followers_user_path(user) }
          it {should have_selector('title', :text => 'Sign In')}
        end
        describe "visit edit page" do
          before{visit edit_user_path(user)}
          it{should have_selector('title', :text => 'Sign In')}
        end
        
        describe "visit index page" do
          before{visit users_path}
          it{should have_selector('title', :text => 'Sign In')}
        end
        
        describe "while submitting to the update action" do
          before { put user_path(user)}
          specify{response.should redirect_to(signin_path)}
        end
        
      end
    end
    
    describe "as a wrong user" do
      let(:user){FactoryGirl.create(:user)}
      let(:wrong_user){FactoryGirl.create(:user, :email => 'wrong@example.com')}
      before{visit signin_path}
      
      describe "while visiting users#edit page" do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_selector('title', :text => full_title('Edit user')) }
      end
      
      describe "while submitting a PUT request to users#update action" do
        before { put user_path(wrong_user)}
        specify { response.should redirect_to(root_path) }
      end
    end
    
    describe "as a non-admin user" do
      let(:user){FactoryGirl.create(:user)}
      let(:non_admin){FactoryGirl.create(:user)}
      
      before{ sign_in non_admin }
      
      it "while issuing DELETE requests to the users#delete action" do
        before { delete user_path(user) }
        specify{response.should redirect_to(root_path)}
      end
    end
    
  end
end
