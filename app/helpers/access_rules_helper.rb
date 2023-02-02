module AccessRulesHelper

# Rules Search Fields - Includes Access Rules, CRUD Rules, Users, Roles and Workspaces

  # Default Rules Search Fields
   def rules_search(show = nil)
    # Default Search
    rules_search = [
      {:tag => :per_page, :name => 'Display',  :options => options_for_select(per_page_options, params[:per_page]),    :html => {class:'search-input auto-submit'}, :can => true},
      {:tag => :workspace_id, :name => 'Workspace', :options => options_for_select(Workspace.order(:name).collect{ |x| [x.name, x.id]}, params[:id]), :html => {class:'search-input auto-submit'}, :can => @workspace.present?},
      {:tag => :role_id, :name => 'Role', :options => options_for_select(Role.order(:name).all.collect{ |x| [x.name, x.id]}, params[:id]), :html => {class:'search-input auto-submit'}, :can => @role.present?}
    ]
    # Users Search (Users And Role)
    if show == 'users'
        rules_search << { :name => 'Status', :tag => :status, :options => options_for_select([['Active', 1], ['Inactive', 0], %w[All all]], params[:status]), :html => { class:'search-input auto-submit'}, :can =>  controller_name == 'users'}
        rules_search << {:name => 'Roles',  :tag => :role_id,  :options => options_for_select(Role.all.collect {|x| [x.name,x.id]}, params[:role_id]), :html => {include_blank: 'All', class:'multiple_select', multiple:true}, :can => controller_name == 'users' }
            # Access Rules Search (Workspace and Role - Rules and Custom Rules)
    elsif show == 'custom_rules' || show == 'rules'
      rules_search << {:tag => :workspace_id, :name => 'Workspaces', :options => options_for_select(Workspace.with_custom_rules(params[:show]), params[:workspace_id]), :html => {class:'multiple_select', multiple:true}, :can => @role.present?}
      rules_search << {:tag => :role_id, :name => 'Roles', :options => options_for_select(Role.all.collect {|x| [x.name,x.id]}, params[:role_id]), :html => {class:'multiple_select', multiple:true}, :can => @workspace.present?}
      rules_search << {:name => 'Status', :tag => :status, :options => options_for_select([['Allowed', 1],['Not Allowed', 0], ['All', 'All']], params[:status].present? ? params[:status] : 1), :html => {class:'search-input auto-submit'}, :can => @role.present? && params[:show] == 'custom_rules'}
    end
    rules_search
  end

  # Access Rules Search Placeholders
  def admin_search_placeholder(view)
    placeholder = {:rules => 'Search on Access Rules.', :users => 'on ID, Name or Email.', :roles => 'on ID, Name or Active Directory.', :workspaces => 'ID or Name.', :custom_rules => 'on Descriptions.'}
    placeholder[view.to_sym]
  end

  # Search on Role (If users, rules or custom rules)
  def role_show(plural = false)
    if params[:show] == 'users' || params[:show].nil?
      (!plural) ? 'User' : 'Users'
    elsif params[:show] == 'rules'
      !plural ? 'Access Rule' : 'Access Rules'
    elsif params[:show] == 'custom_rules'
      !plural ? 'Custom Rule' : 'Custom Rules'
    end
  end

  # Search on Access Rules
  def rule_show
    params[:show].singularize.titleize
  end

  # Which views user can access
  def get_user_admin_rules
    # Available Views
    views = [:role, :workspace, :custom_rule]
    show = []
    # Check User Access
    views.each do |view|
      if can?(view, :search)
      show << view.to_s.pluralize
      end
    end
    # Return Available view Access
    show
  end

  def access_rules_tabs(workspace = nil, show = nil)
    if workspace == 'role' || workspace == 'workspace'
      tabs = []
      tabs << ['Users','users'] if can?(:user,:search) && workspace == 'role'
      tabs << ['Access Rules','rules'] if can?(:rule,:search)
      tabs << ['Custom Rules', 'custom_rules'] if can?(:custom_rule,:search)
      tabs
    else
      tabs = []
      tabs << ['Roles', 'roles'] if can?(:role,:search)
      tabs << ['Workspaces', 'workspaces'] if can?(:workspace,:search)
      tabs << ['Custom Rules', 'custom_rules'] if can?(:custom_rule,:search)
      tabs
    end
    show.present? ? tabs.detect { |x, y| y == show } : tabs
  end

  # Sort Column
  def sort_rules_column
    # Custom Rules
    if params[:show] == 'custom_rules'
      acceptable_cols = %w[admin_workspaces.name admin_roles.name admin_custom_rules.id admin_custom_rules.description]
      default_col = @workspace.present? ? "admin_roles.name" : "admin_custom_rules.description"
    # Roles
    elsif params[:show] == 'roles'
      acceptable_cols = %w[admin_roles.name admin_roles.id admin_roles.ad_dn]
      default_col = "admin_roles.name"
    # Roles
    elsif params[:show] == 'users' || controller_name == 'users'
      acceptable_cols = %w[admin_users.name admin_users.email admin_roles.name admin_users.id]
      default_col = "admin_users.name"
    # Workspaces
    elsif params[:show] == 'workspaces'
      acceptable_cols = %w[admin_workspaces.id admin_workspaces.name admin_custom_rules.id admin_custom_rules.description]
      default_col = "admin_workspaces.name"
    else
      # Rules - Workspace and Role
      acceptable_cols = %w[admin_workspaces.name admin_crud_rules.id admin_crud_rules.c admin_crud_rules.r admin_crud_rules.u admin_crud_rules.d admin_crud_rules.s admin_crud_rules.p]
      default_col =  "admin_workspaces.name" if @role.present?
      default_col = "admin_roles.name" if @workspace.present?
    end
    # Access Rules Index View
    acceptable_cols.include?(params[:sort]) ? params[:sort] : default_col
  end

  # Sort Method
  def rules_sort(column, title)
  title ||= column.titleize
  css_class = column == sort_rules_column ? "current #{asc_sort_direction}" : nil
  direction = column == sort_rules_column && asc_sort_direction == "asc" ? "desc" : "asc"
    link_to title, {
      :sort => column,
      :direction => direction,
      :search => params[:search],
      :full_sentence => params[:full_sentence],
      :per_page => params[:per_page],
      :show => params[:show],
      :status => params[:status],
      :role_id => params[:role_id],
      :workspace_id => params[:workspace_id],
      :account_id => params[:account_id]
    },
    {:class => css_class, :title => "Sort"}
  end

  def user_options_selected(option,user)

  end

def user_options_select(option,user)
  option_selected = params[:option]
  selected = option_selected.present? ? params[:option][option.to_sym] : user.options[option.to_s]
    if option == 'default_account'
      options = user.bank_accounts.active(true).collect{|x| [x.name,x.id]}
    elsif option == 'currency'
      options = user.currencies.collect{|x| [x.name,x.id]}
    elsif option == 'per_page'
      options = per_page_options
    elsif option == 'hide_search'
      options = [['Always',1],['Manual',0]]
    end
    options_for_select(options, selected)
  end

end
