module ApplicationHelper

# ACCESS CHECK HELPER - IMPORTANT

  # User Access Rules Check
  def can?(workspace,action)
    begin
      # Find Rule
      Rule.where(workspace_id: Workspace.where("name = ?", workspace.to_s.pluralize.titleize).first.id, role_id: @current_user.role.id).first.send(action.to_s.first)
    rescue
      #if Rule doesn't exist
      false
    end
  end

  # User Access Rules Custom Check
  def c_can?(code)
    begin
      # Find Rule
      CustomRoleRule.where(custom_rule_id: CustomRule.where(code:code).first.id, role_id: @current_user.role.id).first.access
    rescue
     # if Rule doesn't exist
    false
    end
  end

# APPLICATION UI HELPERS

  # Time Interval for Search
  def search_date_periods
    [['Current Month', 'current_month'], ['Current Year', 'current_year'], ['Last 6 months', 'last_six_months'], ['Last year','last_year'], %w[All all], %w[Custom custom], ]
  end

  # Default Format for Showing Date and Time
  def default_datetime(datetime)
    datetime.strftime('%d %b %Y - %I:%M %p')
  end

  # Default Format to Showing Date
  def default_date(datetime)
    datetime.strftime('%d %b %Y')
  end

# Default Format to Showing Time
  def default_time(datetime)
    datetime.strftime('%I:%M %p')
  end

  # Creates HTML for validation Errors to be used on Flash message.
  def errors_to_string(errors, short = false)
    string = "The following error(s) have been found.<br>"
    current = ""
    errors.messages.each do |attr,msg|
      title = attr.to_s.split('.').first.gsub("scenario_", "").gsub("av", "Media").titleize
      subtitle = attr.to_s.split('.').last.titleize
      string = (current == title ? string + "#{subtitle unless short} #{msg.to_sentence}.<br>" :
                string + "#{"<b>#{title}</b><br>" unless short } #{subtitle unless short} #{msg.to_sentence}<br>")
      current = title
    end
    string.present? ? "<div style='text-align:left;'>#{string}</div>" : ''
  end

  def success_exist_errors(success,exist,errors, skip_pretext = false)
    s_count, e_count, er_count = success.count, exist.count, errors.count
    "#{'Action completed.' unless skip_pretext} #{['<br> Successful: ',success.to_sentence].join if s_count > 0}#{['<br> Exist: ',exist.to_sentence].join if e_count > 0}#{['<br> Failed :',errors.to_sentence].join if er_count > 0}."
  end

  # Return nested fields
  def nested_fields_errors(object,nested_field)
    unless object.errors.nil?
      fields_with_errors = []
      object.errors.messages.each do |attr,msg| fields_with_errors << attr.to_s.split('.').first end
      fields_with_errors.include?(nested_field) ? 'with-nested-errors' : ''
    end
  end


  # Return Row number on index
  def row_number(rows)
    ((params[:page].to_i - 1)*params[:per_page].to_i) + rows
  end

  def per_page_options
    [['5 rows per page', 5], ['10 rows per page', 10],['15 rows per page', 15],['20 rows per page', 20],['50 rows per page', 50], ['100 rows per page', 100],['500 rows per page', 500]]
  end

  def limit_date_options
    [['Last 6 months.', (Time.now - 6.months).to_date],['Last 12 months.', (Time.now - 12.months).to_date],['Last 24 months.', (Time.now - 2.years).to_date],['Remove Limit - Slow', (Time.now - 50.years).to_date]]
  end

  # Return Link if data and Access Right
  def row_link(text,title,path, can = true)
    (can && text.present?) ? (link_to text, path, :title => title == false ? text : title) : ""
  end

  # Sort Direction - Default ASC
  def asc_sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  # Sort Direction - Default DESC
  def desc_sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

  def stop_go_flash(green,yellow,red)
    if green > 0 && yellow == 0 && red == 0 || red > 0 && yellow == 0 && green == 0
      (green > 0 && yellow == 0 && red == 0) ? :notice : :error
    else
      :alert
    end
  end

    # Search Header
  def search_header(icon,title,sidebar = false)
    "<h1><i class='#{icon} search'></i> &nbsp;#{title}</h4>
    <div id='hide-search' #{'class="sidebar"' if sidebar}><i id='hide-search-arrow' class='fad fa-arrow-alt-from-bottom fa-sm'></i><i class='fad fa-search'></i></div>".html_safe
  end

# Drop Down Icon
def drop_icon(icon,workspace = nil)
  case icon
  when :search
    '<i class="fad fa-search loading"></i> &nbsp;  Search'.html_safe
  when :new
    "<i class='fad fa-file-plus drop-icon-swap'></i> &nbsp; New #{workspace}".html_safe
  else
    ''
  end
end

def collect_search_params
  all_params = [:sort,:direction, :search, :bank_account_id, :transaction_type_id, :per_page, :account_id, :period, :sub_category_id]
  params[:search_params] = nil
  all_params.each do |parameter|
    if params[parameter].present?
      params[:search_params] << params[parameter]
    end
  end
end

def account_type_icon(account_type)
  # ['Cash','Everyday', 'Savings', 'Investment', 'Credit Card','System']
  %w[fa-wallet fa-credit-card-blank fa-piggy-bank fa-chart-line fa-credit-card fa-coins][account_type - 1]
end

def accounts_options(new = false)
  @accounts = @current_user.accounts.order(:name).map{|x| [x.name.titleize, x.name[0].match?(/[A-Za-z]/) ? x.name[0].upcase : '#', x.id]}
  @accounts = @accounts.group_by { |c| c[1] }
  if new == true
  @accounts = {'New' => {'Create Account' => 'new_account'}}.merge(@accounts)
  else
    @accounts
  end
end

def categories_options(type = nil)
  categories = @current_user.sub_categories.joins(:category).order('categories.name asc')
  if type.present?
    categories = (type == 'expenses' ? categories.where('categories.category_type != 2') : categories.where('categories.category_type != 3 '))
  end
  categories.map{|l| [l.name, l.category.name, l.id]}.group_by { |c| c[1] }
end

def trans_type_icon(object)
  if object.try(:transfer).present?
    icon = 'fa-exchange'
  else
    icon = object.transaction_type.name == 'expenses' ? 'fa-arrow-alt-up' : 'fa-arrow-alt-down'
  end
  "<i class='fas #{icon}'></i>".html_safe
end

  def currency_with_color(value)
    color = value > 0 ? '#638269' : '#c53e3e'
    "<span style='color:#{color}'> #{number_to_currency(value)} </span>".html_safe
  end



def month_names
  (1..12).collect{|x| [Date::MONTHNAMES[x], x]}
end

def values_to_colors(values_array)
  colors = []
  values_array.each do |value|
    if value > 0
      colors << '#638269'
    elsif value < 0
      colors << '#c53e3e'
    else
      colors << '#838383;'
    end
  end
  colors
end


end




