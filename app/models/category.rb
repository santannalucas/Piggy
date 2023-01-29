class Category < ActiveRecord::Base
  include Filterable

  has_many :sub_categories
  has_many :transactions, through: :sub_categories
  belongs_to :user, foreign_key: 'user_id'


  scope :all_words_search , -> (all_words_search) {where("categories.id = ? OR name LIKE '%#{all_words_search.split.join("%' OR name LIKE '%")}%'", all_words_search)}
  scope :sentence_search, -> (sentence_search) {where("categories.id = ? OR name LIKE '%#{sentence_search}%'", sentence_search)}

  def type_string
    %w[All Deposits Expenses][self.category_type - 1] unless category_type.nil?
  end
end

