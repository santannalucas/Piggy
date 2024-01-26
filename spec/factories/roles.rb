FactoryBot.define do
  factory :admin_role, class: Role do
    name { "Admin" }
    id { 1 }
  end

  factory :role do
    name { "Standard Account" }
    id { 2 }
  end
end