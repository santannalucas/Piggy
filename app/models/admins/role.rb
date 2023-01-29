class Role < ActiveRecord::Base
  self.table_name = "admin_roles"

  include Filterable

  # Validations
  validates :name, presence: { message: "is required"}, uniqueness: { message: "already exist"}

  # Relationship
  has_many :custom_role_rules, :dependent => :destroy
  has_many :custom_rules, through: :custom_role_rules, :dependent => :destroy
  has_many :rules, :dependent => :destroy
  has_many :workspaces, through: :rules
  has_many :users

  # Scopes
  scope :all_words_search, -> (search) {where("admin_roles.id = ? OR admin_roles.name LIKE '%#{search.split.join("%' OR admin_roles.name LIKE '%")}%'", search.to_i)}
  scope :sentence_search, -> (search) {where("admin_roles.id = ? OR admin_roles.name LIKE '%#{search}%' OR admin_roles.ad_dn LIKE '%#{search}%'", search.to_i)}

  def self.rebuild
    Role.all.each do |role|
      Workspace.all.each do |workspace|
        @rule = Rule.where(workspace_id: workspace.id, role_id: role.id).first
        if @rule.nil?
          role.id == 1 ? Rule.create(workspace_id: workspace.id, role_id: role.id, c:1, r:1, u:1, d:1, s:1, p:1) :
            Rule.create(workspace_id: workspace.id, role_id: role.id, c:0, r:0, u:0, d:0, s:0, p:0)
        end
      end
    end
    CustomRule.all.each do |custom_rule|
    @role_rule = CustomRoleRule.where(custom_rule_id: custom_rule.id, role_id: 1).first
      if @role_rule.nil?
        CustomRoleRule.create(custom_rule_id: custom_rule.id, role_id: 1, access: 1)
      end
    end
  end

  def summary_info
    "#{self.name}"
  end

  def self.with_custom_rules
    joins("inner join admin_custom_role_rules on admin_custom_role_rules.admin_role_id = admin_roles.id").order(:name).uniq.collect{ |x| [x.name, x.id]}
  end

end