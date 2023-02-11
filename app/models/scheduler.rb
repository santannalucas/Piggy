class Scheduler < ActiveRecord::Base

  include Filterable

  # Lucas Code
  belongs_to :scheduler_type
  belongs_to :bank_account
  belongs_to :account
  belongs_to :sub_category
  belongs_to :transaction_type
  belongs_to :user
  belongs_to :scheduler_period, required: false
  has_many :scheduler_items, :dependent => :destroy
  has_many :payments, :through => :scheduler_items

  scope :all_words_search , -> (all_words_search) {where("schedulers.id = ? OR description LIKE '%#{all_words_search.split.join("%' OR description LIKE '%")}%'", all_words_search)}
  scope :sentence_search, -> (sentence_search) {where("schedulers.id = ? OR description LIKE '%#{sentence_search}%'", sentence_search)}
  scope :completed, -> (completed) {where(completed:completed)}
  scope :sub_category_id , -> (sub_category_id) {where(sub_category_id:sub_category_id)}
  scope :account_id , -> (account_id) {where(account_id:account_id)}
  scope :bank_account_id , -> (bank_account_id) {where(bank_account_id:bank_account_id)}
  scope :transaction_type_id, -> (transaction_type_id) {where(transaction_type_id:transaction_type_id)}

  accepts_nested_attributes_for :scheduler_items

  validates_presence_of :transaction_type_id, :sub_category_id, :amount
  validates :amount, numericality: { greater_than: 0 }
  validate :payment_type


  before_save :clear_split
  after_update :check_for_completion
  after_create :create_items

  # Validations
  def payment_type
    errors.add(:scheduler_type, "Payment need to be split into more than 2.") if self.scheduler_type.name == 'Split Payments' && (self.split.nil?  || self.split <2)
    errors.add(:scheduler_type, "Select Period.") if self.scheduler_type.name != 'Single Payment' && self.scheduler_period.nil?
  end

  def type_description
    if self.scheduler_type.name == 'Split Payments'
      "#{self.split} Payments of #{'%.2f' % (self.amount/self.split)}"
    elsif self.scheduler_type.name == 'Periodic Payments'
      self.scheduler_period.name
    end
  end

  def type_name
    self.transaction_type.name
  end

  def clear_split
    self.split = nil unless self.scheduler_type.name == 'Split Payments'
  end

  def create_items
    # Single Payment Items
    if self.scheduler_type.name == 'Single Payment' && self.scheduler_items.count == 0
      self.scheduler_items.create(amount:self.amount, created_at:self.created_at)
    # Periodic Payments
    elsif self.scheduler_type.name == 'Periodic Payments' && self.scheduler_items.unpaid.count == 0
      date = self.created_at.to_datetime
      last_date = self.last_payment.to_datetime
      payment = 1
      while date < last_date do
        date = increase_date(date,self.scheduler_period.period_type) unless payment == 1
        self.scheduler_items.create(amount:self.amount, created_at:date.to_datetime)
        payment = payment + 1
      end
      # Split Payments
    elsif self.scheduler_type.name == 'Split Payments' && split != self.scheduler_items.count
      date = self.created_at.to_datetime
      payment = 1
      self.split.to_i.times do
        date = increase_date(date,self.scheduler_period.period_type) unless payment == 1
        self.scheduler_items.create(amount:self.amount/self.split, created_at:date.to_datetime)
        payment = payment + 1
      end
    end
    self.completed = false
  end

  def increase_date(date,period)
    if period == 'month'
      date + self.scheduler_period.months.to_i * 30.days
    elsif period == 'week'
      date + self.scheduler_period.days.days
    end
  end

  def check_for_completion
    name = self.scheduler_type.name
    if !self.scheduler_items.where('scheduler_items.transaction_id IS NULL').present? && (name == 'Split Payments' || name == 'Single Payment')
      self.update_column(:completed,true)
    end
  end


end
