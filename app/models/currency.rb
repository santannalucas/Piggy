class Currency < ActiveRecord::Base
  include Filterable
  belongs_to :user
  has_many :bank_accounts
  has_many :transactions, through: :bank_accounts

  scope :all_words_search , -> (all_words_search) {where("currencies.id = ? OR name LIKE '%#{all_words_search.split.join("%' OR name LIKE '%")}%'", all_words_search)}
  scope :sentence_search, -> (sentence_search) {where("currencies.id = ? OR name LIKE '%#{sentence_search}%'", sentence_search)}


  def name_with_code
    "#{self.name} (#{self.code})"
  end
end

