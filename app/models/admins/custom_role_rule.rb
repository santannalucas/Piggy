class CustomRoleRule < ActiveRecord::Base
  self.table_name = "admin_custom_role_rules"

  include Filterable

  belongs_to :role
  belongs_to :custom_rule
  has_many :users, :through => 'role'

  # Scopes
  scope :all_words_search, -> (all_words_search) {where("admin_custom_rules.id = ? OR admin_custom_rules.name LIKE '%#{all_words_search.split.join("%' OR admin_name LIKE '%")}%'", all_words_search.to_i)}
  scope :sentence_search, -> (sentence_search) {where("admin_custom_rules.id = ? OR admin_custom_rules.name LIKE '%#{sentence_search}%'", sentence_search.to_i)}
  scope :workspace_id, -> (workspace_id) {joins(:custom_rule).where('admin_custom_rules.workspace_id = ?', workspace_id)}
  scope :role_id, -> (role_id) {where(role_id:role_id)}
  scope :status, -> (status) {where(access:status)}

  validates :role_id, :custom_rule_id , presence: true

  scope :all_words_search, -> (all_words_search) {where(CustomRule.text_search(all_words_search))}
  scope :sentence_search, -> (sentence_search) {where(CustomRule.text_search(sentence_search,'sentence'))}

  # Access Logs Details
  def log_details
    "Role: #{self.role.name} - Workspace: #{self.custom_rule.workspace.name} - Custom Rule: #{self.custom_rule.description} - Access #{self.access }"
  end

end
