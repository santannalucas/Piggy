# Demo User Seed

# Rebuild Roles
Role.rebuild

# User.create
@user = User.where(name:"Demo User", email:'demo.user@piggy.onrails.com', role_id:2, active: true).first_or_create
@user.update(password:'Init123')
@user.validate_options

# Create User Categories

categories = [
  ['Expenses',[
     ['Water, Gas & Energy', %w[Water Gas Energy]],
     ['Rent & Mortgage', %w[Rent Maintenance]],
     ['Transport', ['Car Insurance', 'Loan', 'Maintenance', 'Registration']],
     ['Leisure', ['Pubs','Coffee Shops','Cinema', 'Eating Out', 'Fast Food']],
     ['Medical and Insurance', ['Medicine','GP Visits','Health Insurance']],
     ['Subscriptions', %w[Internet Phone TV Software]],
     ['Taxes', ['Income Tax', 'Other taxes']]
  ]],
  ['Income',
   [
    ['Wages',%w[Salary Extra-Hours Bonuses]],
    ['Investment', %w[Funds Stocks Bonds]]
   ]
  ]
]

categories.each do |type|
  puts "Type #{type[0]}"
  if type[0] == 'Expenses'
    category_type = 3
  elsif type[0] == 'Income'
    category_type = 2
  end
  puts "Type Categories #{type[1]}"
  type[1].each do |category|
    puts "Category #{category}"
    @category = @user.categories.where(name:category[0],category_type: category_type).first_or_create
    category[1].each do |sub|
      @category.sub_categories.where(name:sub).first_or_create
    end
  end
end

# Create User Accounts

accounts_costs = {
  'Sydney Water' => 15 ,
  'Vodafone' => 45,
  'Netflix' => 15,
  'Origin' => 70,
  'AGL' => 30,
  'Landlord' => 2200,
  'Allianz' => 50,
  'JetBrains' => 20,
  'Toyota' => 450,
  'Piggy Inc' => 5500,
  'Medicare' => 100,
  'Coles' => 70,
  'McDonalds' => 15,
  'Gas Station' => 50
}

accounts_costs.each do |account|
  @user.accounts.where(name:account[0]).first_or_create
end

# Scheduled Bills
["Sydney Water", "Vodafone", "Netflix", "Origin", "AGL", "Landlord", "Allianz", "JetBrains", "Toyota", "Piggy Inc", "Medicare"].each do |account|
  @scheduler = Scheduler.create(user_id:@user.id, scheduler_type_id: , :bank_account_id, :account_id, :split, :scheduler_period_id, :description, :amount, :sub_category_id, :last_payment, :transaction_type_id, :created_at, :updated_at)







end







# Variable Expenses





