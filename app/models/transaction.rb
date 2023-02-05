class Transaction < ActiveRecord::Base

  # Lucas Code
  include Filterable
  belongs_to :bank_account
  has_one :currency, through: :bank_account
  belongs_to :account, required: false
  belongs_to :sub_category
  has_one :category, through: :sub_category
  has_one :transfer_to, class_name: 'Transfer', :foreign_key => 'to_id', :dependent => :destroy
  has_one :transfer_from, class_name: 'Transfer', :foreign_key => 'from_id', :dependent => :destroy
  belongs_to :transaction_type

  # Search Scopes
  scope :all_words_search , -> (all_words_search) {where("transactions.id = ? OR number LIKE '%#{all_words_search.split.join("%' OR number LIKE '%")}%' OR description LIKE '%#{all_words_search.split.join("%' OR description LIKE '%")}%'", all_words_search)}
  scope :sentence_search, -> (sentence_search) {where("transactions.id = ? OR number LIKE '%#{sentence_search}%' OR description LIKE '%#{sentence_search}%'", sentence_search)}

  # Relationship Scopes
  scope :currency_id, -> (currency_id) {where currency_id: currency_id}
  scope :sub_category_id , -> (sub_category_id) {where(sub_category_id:sub_category_id)}
  scope :account_id , -> (account_id) {where(account_id:account_id)}
  scope :bank_account_id , -> (bank_account_id) {where(bank_account_id:bank_account_id)}
  scope :transaction_type_id, -> (transaction_type_id) {where(transaction_type_id:transaction_type_id)}

  # General Use Scopes
  scope :active, -> (active) {where active: active}
  scope :start_date, -> (start_date) {where('transactions.created_at >= ?', start_date)}
  scope :end_date, -> (end_date) {where('transactions.created_at <= ?', end_date)}
  scope :last_months, -> (month) {where('transactions.created_at >= ? AND transactions.created_at <= ?', (Time.now - month.months).beginning_of_month,(Time.now - month.months).end_of_month)}
  scope :next_months, -> (month) {where('transactions.created_at >= ? AND transactions.created_at <= ?', (Time.now + month.months).beginning_of_month,(Time.now + month.months).end_of_month)}
  scope :deposits, -> {where(transaction_type_id:2)}
  scope :expenses, -> {where(transaction_type_id:3)}
  scope :no_transfers, -> {where('transactions.transfer IS NULL OR transactions.transfer = ?',false)}
  scope :year_month, -> (year,month) {where('transactions.created_at >= ? AND transactions.created_at <= ?', Time.new(year,month).beginning_of_month, Time.new(year,month).end_of_month)}

  # Scope for Default Periods
  scope :current_month, -> {where('transactions.created_at >= ? AND transactions.created_at <= ?', Time.now.beginning_of_month, Time.now.end_of_month)}
  scope :current_year, -> {where('transactions.created_at >= ? AND transactions.created_at <= ?', Time.now.beginning_of_year, Time.now.end_of_year)}
  scope :last_month, -> {last_months(1)}
  scope :last_quarter, -> {where('transactions.created_at >= ? AND transactions.created_at <= ?', Time.now.beginning_of_month - 2.months, Time.now.end_of_month)}
  scope :last_six_months, -> {where('transactions.created_at >= ? AND transactions.created_at <= ?', Time.now.beginning_of_month - 5.months, Time.now.end_of_month)}
  scope :last_year, -> {where('transactions.created_at >= ? AND transactions.created_at <= ?', (Time.now - 1.year).end_of_day, Time.now.end_of_day)}
  scope :next_month, -> {next_months(1)}
  scope :next_quarter, -> {where('transactions.created_at >= ? AND transactions.created_at <= ?', Time.now.beginning_of_month, Time.now.end_of_month + 2.months)}
  scope :next_six_months, -> {where('transactions.created_at >= ? AND transactions.created_at <= ?', Time.now.beginning_of_month, Time.now.end_of_month + 5.months)}
  scope :next_year, -> {where('transactions.created_at >= ? AND transactions.created_at <= ?', (Time.now + 1.year).end_of_day, Time.now.end_of_day)}





  validates :amount, numericality: { greater_than: 0 }


  def transfer_or_account_name
    if self.transfer.present?
      self.transaction_type == 3 ? self.transfer_ref.from_bank_account.bank_account.name : self.transfer_ref.to_bank_account.bank_account.name
    else
      self.account.try(:name)
    end
  end

  def amount_to_string
    self.transaction_type_id == 3 ? "$ (#{'%.2f' % self.amount})" : "$ #{'%.2f' % self.amount}"
  end

  def transfer_ref
    Transfer.where('from_id = ? OR to_id = ?', self.id, self.id).try(:first)
  end

  def self.total
    sum(:amount)
  end


  def self.monthly_total(user, year = nil, currency_id = nil)
    currency = Currency.find(currency || user.options['currency'])
    transactions = user.transactions
    total = []
    (1..12).to_a.each do |month|
      start = year.present? ? Time.new(year) : Time.now
      start = start.beginning_of_year + (month - 1).months
      ended = start.end_of_month
      deposits = transactions.deposits.start_date(start).end_date(ended).total_in_currency(user, currency.id)
      expenses = transactions.expenses.start_date(start).end_date(ended).total_in_currency(user, currency.id)
      total << [Date::MONTHNAMES[month], deposits, expenses]
    end
    total
  end

  def self.monthly_results(user, year = nil, currency_id = nil)
    self.monthly_total(user, year , currency_id).collect{|x|[x[0],(x[1]-x[2]).round(2)]}
  end

  def self.total_in_currency(user,currency_id = nil)
    currency = Currency.find(currency || user.options['currency'])
    totals = self.where('bank_accounts.user_id = ?',user.id).collect{|t| t.amount/currency.rate }
    total = 0
    totals.each do |transaction|
      total += transaction
    end
    total.round(2)
  end

  def self.balance
    self.deposits.total - self.expenses.total
  end

end

