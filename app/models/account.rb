class Account < ActiveRecord::Base

  # Lucas Code
  include Filterable

  validates_presence_of :name

  has_many :transactions
  belongs_to :user
  has_one :transfer

  scope :all_words_search , -> (all_words_search) {where("accounts.id = ? OR name LIKE '%#{all_words_search.split.join("%' OR name LIKE '%")}%' OR description LIKE '%#{all_words_search.split.join("%' OR description LIKE '%")}%'", all_words_search)}
  scope :sentence_search, -> (sentence_search) {where("accounts.id = ? OR number LIKE '%#{sentence_search}%' OR description LIKE '%#{sentence_search}%'", sentence_search)}




end

