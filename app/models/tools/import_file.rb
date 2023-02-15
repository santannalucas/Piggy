class ImportFile < ActiveRecord::Base
  validates_uniqueness_of :name
  serialize :options

end

