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

accounts_costs = {  'Sydney Water' => 15 , 'Vodafone' => 45, 'Netflix' => 15, 'Origin' => 70, 'AGL' => 30, 'Landlord' => 2200, 'Allianz' => 50, 'JetBrains' => 20,
                    'Toyota' => 450, 'Piggy Inc' => 5500, 'Medicare' => 100, 'Coles' => 70, 'McDonalds' => 15, 'Gas Station' => 50 }

# accounts_costs.each do |account|
#   @user.accounts.where(name:account[0]).first_or_create
# end

# Scheduled Bills
accounts_and_categories = [
  ["Sydney Water","Water"],
  ["Vodafone", "Phone"],
  ["Netflix","TV"],
  ["Origin","Energy"],
  ["AGL","Gas"],
  ["Landlord","Rent"],
  ["Allianz","Car Insurance"],
  ["JetBrains","Software"],
  ["Toyota","Loan"],
  ["Medicare","Health Insurance"]
]

accounts_and_categories.each do |account|
  @scheduler = Scheduler.create(
    user_id:@user.id,
    scheduler_type_id:3 ,
    bank_account_id: @user.bank_account.id,
    account_id: @user.accounts.where(name:account[0]).first.id,
    scheduler_period_id:5,
    amount:accounts_costs[account[0]],
    sub_category_id: @user.sub_categories.where(name:account[1]).first.id,
    last_payment: Time.now.end_of_year,
    transaction_type_id: 3,
    created_at: (Time.now - 1.year).beginning_of_year
  )
end

@user.scheduler_items.unpaid.where("scheduler_items.created_at < ?", Time.now).each do |x| x.pay end






# Variable Expenses





