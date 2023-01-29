class Workspace < ActiveRecord::Base
  self.table_name = "admin_workspaces"

  include Filterable

  # Relationships
  has_many :rules, :dependent => :destroy
  has_many :roles, through: :rules
  has_many :custom_rules, :dependent => :destroy
  has_many :custom_role_rules, through: :custom_rules

  # Validations
  validates_uniqueness_of :name

  # Scopes
  scope :all_words_search, -> (all_words_search) {where("admin_workspaces.id = ? OR admin_workspaces.name LIKE '%#{all_words_search.split.join("%' OR admin_workspaces.name LIKE '%")}%'", all_words_search.to_i)}
  scope :sentence_search, -> (sentence_search) {where("admin_workspaces.id = ? OR admin_workspaces.name LIKE '%#{sentence_search}%'", sentence_search.to_i)}

  def self.with_custom_rules(show)
    (show != 'rules' ? joins("inner join admin_custom_rules on admin_workspaces.id = admin_custom_rules.workspace_id") : all).order(:name).uniq.collect{ |x| [x.name, x.id]}
  end

end
