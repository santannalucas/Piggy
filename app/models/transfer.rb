class Transfer < ActiveRecord::Base

  # Lucas Code
  belongs_to :from_bank_account, foreign_key: 'from_id', class_name: 'Transaction', :dependent => :destroy
  belongs_to :to_bank_account, foreign_key: 'to_id', class_name: 'Transaction', :dependent => :destroy
  has_one :user, :through => 'from_bank_account'

  validates :rate, numericality: { greater_than: 0 }
  validates_presence_of :from_bank_account, :to_bank_account
  validates_associated :from_bank_account, :to_bank_account
  validate :validate_transfers_params

  accepts_nested_attributes_for :from_bank_account
  accepts_nested_attributes_for :to_bank_account

  # Validations
  def to_string
    "Transfer of #{from_bank_account.amount} from #{from_bank_account.bank_account.name} to #{to_bank_account.bank_account.name}"
  end

  def initialize_transfer
    self.from_bank_account = Transaction.new if self.from_bank_account.nil?
    self.to_bank_account = Transaction.new  if self.to_bank_account.nil?
    self
  end

  def from_bank
    from_bank_account.bank_account
  end

  def to_bank
    to_bank_account.bank_account
  end

  def validate_transfers_params
    errors.add(:from_bank_account, "Missing Amount.") if self.from_bank_account.amount.nil?
    errors.add(:to_bank_account, "Missing.") if self.to_bank_account.amount.nil?
  end

  # Return the Transfer Account
  def transfer_account(account)
    account == from_bank_account.bank_account ? to_bank_account.bank_account : from_bank_account.bank_account
  end

end
