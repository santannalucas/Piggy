class SchedulerItem < ActiveRecord::Base

  # Lucas Code
  belongs_to :scheduler
  belongs_to :payment, class_name: 'Transaction', :foreign_key => 'transaction_id', :required => false

  scope :unpaid, -> {where('scheduler_items.transaction_id IS NULL')}
  scope :paid, -> {where('scheduler_items.transaction_id IS NULL')}
  scope :year_month, -> (year,month) {where('scheduler_items.created_at >= ? AND scheduler_items.created_at <= ?', Time.new(year,month).beginning_of_month, Time.new(year,month).end_of_month)}
  scope :current_month, -> {where('scheduler_items.created_at >= ? AND scheduler_items.created_at <= ?', Time.now.beginning_of_month, Time.now.end_of_month)}

  def summary
    "#{self.trans_type} $ <b>#{ ('%.2f' % self.amount)}</b> to <b>#{self.destination}</b> from #{self.scheduler.bank_account.name}".html_safe
  end


  def trans_type
    trans_type = self.scheduler.transaction_type_id
    if trans_type == 1
      'Transfer'
    elsif trans_type == 2
      'Receive'
    elsif trans_type == 3
      'Pay'
    end
  end

  def destination
    self.trans_type == 'Transfer' ? BankAccount.find(self.scheduler.transfer_bank_id).name : self.scheduler.account.name
  end


end
