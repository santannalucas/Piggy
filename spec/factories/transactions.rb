FactoryBot.define do
  factory :transaction do
    bank_account # Assuming you have a factory for BankAccount
    account # Assuming you have a factory for Account
    sub_category # Assuming you have a factory for SubCategory
    description { Faker::Lorem.sentence }
    created_at { Faker::Time.between(from: 1.year.ago, to: Time.zone.now) }
    updated_at { created_at }

    trait :deposit do
      transaction_type { 02 }
      amount { Faker::Number.decimal(l_digits: 2) }
    end

    trait :expense do
      transaction_type { 03 }
      amount { Faker::Number.decimal(l_digits: 2) }
    end

    trait :other do
      transaction_type { 01 }
      amount { Faker::Number.decimal(l_digits: 2) }
    end
  end
end