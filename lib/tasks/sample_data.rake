namespace :db do
  desc 'fill database with sample data'
    task :populate => :environment do
      admin=User.create!(:name => 'David Filo',
                         :email => 'david@example.com',
                         :password => 'business1',
                         :password_confirmation => 'business1')
      admin.toggle!(:admin)                   
      User.create!(:name => 'Example User',
                   :email => 'example@railstutorial.org',
                   :password => 'password',
                   :password_confirmation => 'password')
      99.times do |n|
        name=Faker::Name.name
        email="example-#{n+1}@railstutorial.org"
        password="password"
        User.create!(:name => name,
                     :email => email,
                     :password => password,
                     :password_confirmation => password)
      end    
  end
end