FactoryBot.define do

  # Accounts are not bank accounts, they are any account that can be used to track transactions, like super markets, gas stations. bills etc. They only need name and description.
  factory :account do
    name { Faker::Lorem.sentence }
    description { Faker::Lorem.sentence }
    user
  end


end

