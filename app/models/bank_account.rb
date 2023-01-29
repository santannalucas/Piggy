class BankAccount < ActiveRecord::Base

  # Lucas Code
  include Filterable

  belongs_to :user
  belongs_to :currency
  has_many :schedulers
  has_many :transactions
  has_many :accounts, through: :transactions

  validates_presence_of :currency_id, :account_type, :name

  scope :all_words_search , -> (all_words_search) {where("bank_accounts.id = ? OR number LIKE '%#{all_words_search.split.join("%' OR number LIKE '%")}%' OR description LIKE '%#{all_words_search.split.join("%' OR description LIKE '%")}%'", all_words_search)}
  scope :sentence_search, -> (sentence_search) {where("bank_accounts.id = ? OR number LIKE '%#{sentence_search}%' OR description LIKE '%#{sentence_search}%'", sentence_search)}
  scope :currency_id, -> (currency_id) {where currency_id: currency_id}
  scope :active, -> (active) {where active: active}
  scope :start_date, -> (start_date) {where('bank_accounts.created_at >= ?', start_date)}
  scope :end_date, -> (end_date) {where('bank_accounts.created_at <= ?', end_date)}
  scope :dashboard, -> {where(dashboard:true)}
  def total(value_only = false)
    self.transactions.where(transaction_type:02).sum(:amount) - self.transactions.where(transaction_type:03).sum(:amount)
  end

  def name_currency
    "#{name} - (#{currency.code})"
  end

  def account_type_name
    account_types = {1 => 'Cash',2 =>'Everyday',3 =>'Savings', 4 =>'Investment', 5 =>'Credit Card'}
    account_types[self.account_type]
  end

  def converted_rate(other_account)
    other_account.currency == self.currency ? 1 : (self.currency.rate/other_account.currency.rate)
  end

  def total_status
    if self.total(true) > 0
      'deposit'
    elsif self.total(true) < 0
      'expenses'
    end
  end

  def year_select_options(year)
    first = self.transactions.present? ? self.transactions.order(:created_at).first.created_at.year.to_i : (year + 5)
    last =  self.transactions.present? ? self.transactions.order(:created_at).last.created_at.year.to_i : (year - 5)
    (first..last).collect{|x| x}
  end

end

