class CustomRule < ActiveRecord::Base
  self.table_name = "admin_custom_rules"

  include Filterable

  has_many :custom_role_rules
  has_many :roles, through: :custom_role_rules
  belongs_to :workspace

  validates_presence_of :code, :description, :long_description, :workspace
  # Scopes
  scope :all_words_search, -> (all_words_search) {where(CustomRule.text_search(all_words_search))}
  scope :sentence_search, -> (sentence_search) {where(CustomRule.text_search(sentence_search,'sentence'))}
  scope :workspace_id, -> (workspace_id) {where(workspace_id: workspace_id)}

  # SQL Text Search Columns
  TEXT_SEARCH_COLUMNS = %w(admin_custom_rules.description admin_custom_rules.long_description)

  # SQL Query for Text Search
  def self.text_search(param, type = 'all')
    query = ""
    type == 'all' ?
      TEXT_SEARCH_COLUMNS.each do |column| query = query + " #{column} LIKE '%#{param.split.join("%' OR #{column} LIKE '%")}%' OR" end :
      TEXT_SEARCH_COLUMNS.each do |column| query = query + " #{column} LIKE '%#{param}%' OR" end
    query.delete_suffix('OR')
  end

  def self.not_assigned(role_id)
    where("NOT EXISTS (SELECT * FROM admin_custom_role_rules WHERE admin_custom_rules.id = admin_custom_role_rules.custom_rule_id AND admin_custom_role_rules.role_id = ?)", role_id)
  end

  def self.workspaces_not_assigned(role_id, type = nil)
    workspaces = Workspace.where(id: CustomRule.not_assigned(role_id).joins(:workspace).collect { |x| x.workspace_id }).uniq
    type == 'collect' ? workspaces.collect {|x| [x.name,x.id]} : workspaces
  end

  def name
    "<span style='width:20%'> #{self.workspace.name} </span> - #{self.description} - #{self.long_description}"
  end

  def summary_info
    "#{self.workspace.name} - #{self.description} - #{self.long_description}"
  end


end