require 'spec_helper'

describe "UserPages" do
  subject {page}
  shared_examples_for 'user pages' do
    it{should have_selector('h1', :text => heading)}
    it{should have_selector('title', :text => full_title(page_title))}
  end
  before {visit signup_path}
  let(:heading) {'Sign Up'}
  let(:page_title) {'Sign Up'}
end
