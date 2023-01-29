class AccessLog < ActiveRecord::Base
  self.table_name = "admin_access_logs"

  include Filterable

  # Relationship
  belongs_to :user
  belongs_to :role
  belongs_to :workspace

  # Scopes
  scope :rule_name, -> (rule_type) {where("admin_access_logs.access_rule LIKE '%#{rule_type.split.join("%' OR admin_access_logs.access_rule LIKE '%")}%'")}
  scope :user_id, -> (user_id) {where(user_id:user_id)}
  scope :role_id, -> (role_id) {where(role_id:role_id)}
  scope :workspace_id, -> (workspace_id) {where(workspace_id:workspace_id)}
  scope :start_date, -> (start_date) {where('admin_access_logs.created_at >= ?', start_date)}
  scope :end_date, -> (end_date) {where('admin_access_logs.created_at <= ?', end_date)}
  scope :all_words_search, -> (all_words_search) {where(AccessLog.text_search(all_words_search))}
  scope :sentence_search, -> (sentence_search) {where(AccessLog.text_search(sentence_search, 'sentence'))}

  # SQL Text Search Columns
  TEXT_SEARCH_COLUMNS = %w(admin_access_logs.details admin_access_logs.action)

  # SQL Query for Text Search
  def self.text_search(param, type = 'all')
    query = param.to_i == 0 ? "" : "admin_access_logs.id = #{param.to_i} OR "
    type == 'all' ?
      TEXT_SEARCH_COLUMNS.each do |column| query = query + "#{column} LIKE '%#{param.split.join("%' OR #{column} LIKE '%")}%' OR " end :
      TEXT_SEARCH_COLUMNS.each do |column| query = query + "#{column} LIKE '%#{param}%' OR " end
    query[0...-3]
  end

  # SQL Text Search columns to Human
  def self.text_search_help
    TEXT_SEARCH_COLUMNS.collect{ |x| x.gsub("admin_access_logs.", "").titleize}.to_sentence
  end

  def self.rules_names
    %w[Create Custom Delete Login Read Role Search Update View]
  end

  def details_limited
    if self.details.present?
      overflow = self.details.size > 80
      details_icon = "<i class='fas fa-question-circle access-logs-details' title='#{self.details.to_s}'></i> &nbsp;"
      details_limited = self.details[0..80]
      overflow ? "#{details_icon}#{details_limited}...".html_safe : self.details.html_safe
    end
  end

  def change_summary_info
    change.changed_object.summary_info if change.present?
  end

end