class SchedulerType < ActiveRecord::Base

  # Lucas Code
  has_many :schedulers

  def self.rebuild
    SchedulerType.where(name:'Single Payment').create(name:'Single Payment')
    SchedulerType.where(name:'Split Payments').create(name:'Split Payments')
    SchedulerType.where(name:'Periodic Payments').create(name:'Periodic Payments')
  end

end
