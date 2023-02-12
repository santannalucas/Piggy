class SchedulerType < ActiveRecord::Base

  # Lucas Code
  has_many :schedulers

  def self.rebuild
    SchedulerType.where(name:'Single Payment').first_or_create
    SchedulerType.where(name:'Split Payments').first_or_create
    SchedulerType.where(name:'Periodic Payments').first_or_create
  end

end
