FactoryBot.define do
  factory :currency do
    name { "Australian Dollar" }
    code { "AUD" }
    rate { 1 }
  end

  factory :currency_usd, class: Currency do
    name { "United States Dollar" }
    code { "USD" }
    rate { 0.75 }
  end

  factory :currency3, class: Currency do
    name { "Euro" }
    code { "EUR" }
    rate { Faker::Number.decimal(l_digits: 2) }
  end

  factory :currency4, class: Currency do
    name { "Brazilian Real" }
    code { "BRL" }
    rate { 3 }
  end

  factory :currency5, class: Currency do
    name { "Japanese Yen" }
    code { "JPY" }
    rate { 80 }
  end

  factory :currency6, class: Currency do
    name { "Chinese Yuan" }
    code { "CNY" }
    rate { 5 }
  end
end
