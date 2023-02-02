module ReportsHelper

  # Images Search Fields
  def reports_search
    [{:name => 'Display:',     :tag => :per_page,            :options => options_for_select(per_page_options, params[:per_page]),                   :html => {class:'search-input auto-submit'}, :can => true  }]
  end

  # Sort Column
  def reports_sort_column
    acceptable_cols = %w(reports.name)
    acceptable_cols.include?(params[:sort]) ? params[:sort] : "reports.name"
  end

  # Sort Method
  def reports_sort(column, title = nil)
    title ||= column.titleize
    css_class = column == transactions_sort_column ? "current #{desc_sort_direction}" : nil
    direction = column == transactions_sort_column && desc_sort_direction == "desc" ? "asc" : "desc"
    link_to title, {:sort => column, :direction => direction, :search => params[:search], :bank_account_id => params[:bank_account_id], :transaction_type_id => params[:transaction_type_id], :per_page => params[:per_page], :account_id => params[:account_id_id], :period => params[:period], :sub_category_id => params[:sub_category_id]}, {:class => css_class, :title => "Sort"}
  end

end
