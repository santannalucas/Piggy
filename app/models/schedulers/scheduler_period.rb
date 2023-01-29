class SchedulerPeriod < ActiveRecord::Base

  # Lucas Code
  has_many :schedulers

  def self.rebuild
    SchedulerPeriod.where(name:'Every week').first_or_create(name:'Every week', days:7)
    SchedulerPeriod.where(name:'Every 2 weeks').first_or_create(name:'Every 2 weeks', days:14)
    SchedulerPeriod.where(name:'Every 3 weeks').first_or_create(name:'Every 3 weeks', days:28)
    SchedulerPeriod.where(name:'Every 4 weeks').first_or_create(name:'Every 4 weeks', days:28)
    SchedulerPeriod.where(name:'Every Month').first_or_create(name:'Every Month', months:1)
    SchedulerPeriod.where(name:'Every 2 Months').first_or_create(name:'Every 2 Months', months:2)
    SchedulerPeriod.where(name:'Every 3 Months').first_or_create(name:'Every 3 Months', months:3)
    SchedulerPeriod.where(name:'Every 4 Months').first_or_create(name:'Every 4 Months', months:4)
    SchedulerPeriod.where(name:'Every 6 Months').first_or_create(name:'Every 6 Months', months:6)
    SchedulerPeriod.where(name:'Every Year').first_or_create(name:'Every Year', months:12)
  end

  def period_type
    if self.days.nil? && self.months.present?
      'month'
    elsif self.days.present? && self.months.nil?
      'week'
    else
      'undefined'
    end
  end

end
