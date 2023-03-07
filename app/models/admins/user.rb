class User < ActiveRecord::Base
  self.table_name = "admin_users"

  belongs_to :role
  has_many :bank_accounts, :dependent => :destroy
  has_many :currencies, :dependent => :destroy
  has_many :transactions, through: :bank_accounts, :dependent => :destroy
  has_many :accounts, :dependent => :destroy
  has_many :categories, :dependent => :destroy
  has_many :sub_categories, through: :categories, :dependent => :destroy
  has_many :schedulers
  has_many :scheduler_items, through: :schedulers, :dependent => :destroy
  has_many :rules, through: :role
  has_many :workspaces, :class_name => 'Workspace', through: :rules


  serialize :options
  serialize :navbar
  # Token Attribute

  attr_accessor :remember_token

  # Email Regex
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  # User Data Validation
  include Filterable

  before_save { self.email = email.downcase }
  before_update :validate_options

  validates :name,
            presence: true,
            length: { maximum: 50 }

  validates :email,
            presence: true,
            length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX }

  # Access Control Details

  has_secure_password

  validates :password,
            presence: true,
            length: { minimum: 6 },
            allow_nil:true


  scope :role_id, -> (role_id) {where(role_id:role_id)}
  scope :active, -> {where("admin_users.active = ? AND admin_users.role_id IS NOT NULL", true )}
  scope :inactive, -> {where("admin_users.active = 0 OR admin_users.role_id IS NULL" )}
  scope :all_words_search, -> (all_words_search) {where(User.text_search(all_words_search))}
  scope :sentence_search, -> (sentence_search) {where(User.text_search(sentence_search, 'sentence'))}

  def self.status(params)
    not_all = params.to_i == 1 ? active : inactive
    params == 'all' ? all : not_all
  end
  # Returns the hash digest of the given string.

  def load_navbar
    navbar = {}
      self.rules.each do |rule|
        navbar[rule.workspace.name.singularize.parameterize.underscore.to_sym] = {:create => rule.c, :read => rule.c, :update => rule.u, :delete => rule.d, :search => rule.s}
      end
    self.update(navbar:navbar)
  end

  def total_on_period(year,month,transaction_type,bank_account_id)
    types = {'expenses' => 3, 'deposits' => 2, 'all' => [3,2]}
    cat_totals = []
    date = Time.new(year,month)
    bank_account = bank_account_id || self.bank_account.id
    transactions = self.transactions.no_transfers.where("transactions.created_at >= ? AND transactions.created_at <= ?",date.beginning_of_month,date.end_of_month).where(transaction_type:types[transaction_type || 'all'])
    transactions = transactions.where(bank_account_id: bank_account)
    currencies = Currency.where(id:transactions.joins(:bank_account,:currency).pluck('currencies.id').uniq)
    sub_categories = SubCategory.where(id:transactions.collect{|x| x.sub_category.id}).uniq
    sub_categories.each do |sub_category|
      total = 0
      currencies.each do |currency|
        total = total + ((transactions.joins(:bank_account,:currency).where('currencies.id = ? AND sub_category_id = ?',currency.id, sub_category.id).sum('transactions.amount'))/currency.rate)
      end
      cat_totals << [sub_category.name.html_safe,total.round(02)]
    end
    totals = (cat_totals.sort_by { |x| x[1] }.reverse).first(12)
    others = 0
    (cat_totals - totals).each do |key, value| others = others + value end
    totals << ['Others', others.round(2)]
  end

  def total_balance(start,finish,period='year',banks=nil)
    banks = self.bank_account.id if banks.nil?
    transactions = self.transactions.where(bank_account_id:banks).where("transactions.created_at <= ? AND transactions.created_at >= ?",finish,start)
    balance = self.transactions.where(bank_account_id:banks).where("transactions.created_at < ?",start).balance.round(2)
    data = [["#{[start.month,start.year].join('/')}", balance.round(2)]]
    while start < finish do
      case period
      when 'month'
        period_end = start + 1.month
      else
        period_end = start + 1.year
      end
          balance = (balance + transactions.where('transactions.created_at >= ? AND transactions.created_at <= ?',start,period_end).balance).round(2)
          data << ["#{[period_end.month,period_end.year].join('/')}", balance ]
          start = period_end
        end
    data
  end



  def current_month_payments(year,month)
    payments = {
      :paid => {:expenses =>{}, :deposits =>{}},
      :unpaid => {:expenses =>{}, :deposits =>{}}
    }
    date = Time.new(year,month)
    bills = self.scheduler_items.joins(:scheduler).where('scheduler_items.created_at > ? AND scheduler_items.created_at < ?', date.beginning_of_month, date.end_of_month)
    payments[:paid][:deposits] = bills.paid.where('schedulers.transaction_type_id = 2').map{|x| [x.created_at.strftime('%d'), x.summary]}.group_by { |c| c[0] }
    payments[:paid][:expenses] = bills.paid.where('schedulers.transaction_type_id = 3').map{|x| [x.created_at.strftime('%d'), x.summary]}.group_by { |c| c[0] }
    payments[:unpaid][:deposits] = bills.unpaid.where('schedulers.transaction_type_id = 2').map{|x| [x.created_at.strftime('%d'), x.summary]}.group_by { |c| c[0] }
    payments[:unpaid][:expenses] = bills.unpaid.where('schedulers.transaction_type_id = 3').map{|x| [x.created_at.strftime('%d'), x.summary]}.group_by { |c| c[0] }
    payments
  end

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
             BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def bank_account
    BankAccount.find(self.options['default_account'])
  end

  # Remembers a user in the database for use in persistent sessions.

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest.

  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Forgets a user.

  def forget
    update_attribute(:remember_digest, nil)
  end

  def initials
    initials = self.name.split
    initials.count > 1 ? [initials[0][0],initials[1][0]].join.upcase : [initials[0][0],initials[0][initials[0].length - 1]].join.upcase
  end

  def currency
    Currency.find(self.options['currency'])
  end


  def validate_options
    self.options = {} if self.options.nil?
    curr = Currency.where(id:self.options['currency']).try(:first) || self.currencies.try(:first)
    curr = Currency.create(user_id:self.id, name:'Default Currency', rate:1, code:'DFT') if curr.nil?
    bank = BankAccount.where(id:self.options['default_account']).try(:first)|| self.bank_accounts.try(:first)
    bank = BankAccount.create(name:'Default Account', user_id:self.id, account_type: 1, currency_id: curr.id, active:true, dashboard:true) if bank.nil?
    per_page = [5, 10, 15, 20, 50, 100, 500].include?(self.options['per_page']) ? self.options['per_page'] : 15
    hide_search = [0,1].include?(self.options['hide_search']) ? self.options['hide_search'] : 0
    self.update_column(:options,{'default_account' => bank.id, 'currency' => curr.id, 'per_page' => per_page, 'hide_search' => hide_search})
  end

  def categories_on_period(start, finish, banks)
    expenses = []
    deposits = []
    banks = self.bank_account.id if banks.nil?
    transactions = self.transactions.no_transfers.where(bank_account_id:banks).where("transactions.created_at <= ? AND transactions.created_at >= ?",finish,start)
    categories = SubCategory.where(id:transactions.collect{|x| x.sub_category_id}.uniq)
    categories.each do |category|
      inbound = transactions.no_transfers.where(transaction_type_id: 2, sub_category_id:category).total
      deposits << [category.name, inbound] if inbound != 0
      outbound = transactions.where(transaction_type_id:3, sub_category_id:category).total
      expenses << [category.name, outbound] if outbound != 0
    end
    { :expenses => expenses, :deposits => deposits}
  end

  def api_user_data
    { name: self.name, email: self.email, navbar: self.navbar}
  end

  def navbar_json
    available_icons = []
    nav = self.navbar
    [
      { name: "User Management", icon_type:"text", icon:"user-initials",
        contents:{
          user:{active:true,href:"/Admin/User", icon:"fad fa-user", title:self.try(:name)},
          dashboard:{active:true, href:"/", icon:'fad fa-chalkboard', title:"Dashboard"},
          access_rules:{active:nav[:rule][:read], href:"/Admin/Ruses", icon:"fad fa-user-lock", title:"Access Rules"},
          users:{active:nav[:user][:search],href:"/Admin/Users", icon:"fad fa-users", title:"Users"}
        }},
      { name: "Transactions", icon_type:"icon", icon:"fad fa-arrow-right-arrow-left",
        contents:{
          transactions:{active:nav[:transaction][:search],href:"/Transactions", icon:"fad fa-right-left", title:"Transactions"},
          schedulers:{active:nav[:transaction][:search],href:"/Schedulers",icon:"fad fa-calendar", title:"Scheduler"},
          reports:{active:nav[:report][:search],href:"/Reports",icon:"fad fa-chart-column", title:"Reports"}
        }},
      { name:"Configuration", icon_type:"icon", icon:"fad fa-gear",
        contents:{
          bank_accounts:{active:nav[:bank_account][:search],href:"/Config/BankAccounts",icon:"fad fa-sack-dollar", title:"Bank Accounts"},
          accounts:{active:nav[:account][:search],href:"/Config/Accounts",icon:"fad fa-address-book", title:"Accounts"},
          categories:{active:nav[:category][:search],href:"/Config/Categories",icon:"fad fa-folder", title:"Categories"},
          sub_categories:{active:nav[:category][:search],href:"/Config/SubCategories",icon:"fad fa-folder-tree", title:"Sub-Categories"},
          currencies: {active:nav[:currency][:search],href:"/Config/Currencies",icon:"fad fa-circle-dollar", title:"Currencies"}
        }}
    ].each do |dropdown|
      # Add Parent and Children if one or more is available
      if dropdown[:contents].collect{ |o| o[1][:active]}.include?(true)
        available = []
        dropdown[:contents].each do |content| available << content if content[1][:active] end
        available_icons << [dropdown[:name],dropdown[:icon_type],dropdown[:icon],available ]
      end
    end
    available_icons.to_json
  end

end

