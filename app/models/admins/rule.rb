class Rule < ActiveRecord::Base
  self.table_name = "admin_crud_rules"

  include Filterable

  belongs_to :role
  belongs_to :workspace


  # Scopes
  scope :all_words_search, -> (all_words_search) {joins(:workspace, :role).where(Rule.text_search(all_words_search))}
  scope :sentence_search, -> (sentence_search) {joins(:workspace, :role).where(Rule.text_search(sentence_search,'sentence'))}
  scope :workspace_id, -> (workspace_id) {where(workspace_id:workspace_id)}
  scope :role_id, -> (role_id) {where(role_id:role_id)}

  # SQL Text Search Columns
  TEXT_SEARCH_COLUMNS = %w(admin_roles.name admin_workspaces.name)

  # SQL Query for Text Search
  def self.text_search(param, type = 'all')
    query = ""
    type == 'all' ?
      TEXT_SEARCH_COLUMNS.each do |column| query = query + " #{column} LIKE '%#{param.split.join("%' OR #{column} LIKE '%")}%' OR" end :
      TEXT_SEARCH_COLUMNS.each do |column| query = query + " #{column} LIKE '%#{param}%' OR" end
    query.delete_suffix('OR')
  end




end
