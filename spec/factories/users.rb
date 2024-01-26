FactoryBot.define do
  factory :admin_user, class: User do
    name { "Test User" }
    email { "piggyonrails@gmai.com" }
    active { true }
    options { {} }
    password { "123456" }
  end

  factory :user do
    name { "Test User" }
    email { Faker::Internet.email }
    active { true }
    options { {} }
    password { Faker::Internet.password(min_length: 6) }
    role { Role.find_by(name: "Standard Account") || create(:role) }
  end
end
