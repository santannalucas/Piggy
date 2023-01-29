class SubCategory < ActiveRecord::Base
  include Filterable

  has_many :transactions
  belongs_to :category

  scope :all_words_search , -> (all_words_search) {where("sub_categories.id = ? OR name LIKE '%#{all_words_search.split.join("%' OR name LIKE '%")}%'", all_words_search)}
  scope :sentence_search, -> (sentence_search) {where("sub_categories.id = ? OR name LIKE '%#{sentence_search}%'", sentence_search)}
  scope :category_id, -> (category_id) {where(category_id:category_id)}

end

