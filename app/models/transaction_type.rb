class TransactionType < ActiveRecord::Base

    # Lucas Code
    include Filterable
    has_many :transactions
    has_many :schedulers

end
