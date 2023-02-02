module AccountsHelper

  # Images Search Fields
  def accounts_search
    [
     {:name => 'Display',   :tag => :per_page,          :options => options_for_select(per_page_options, params[:per_page]),                   :html => {class:'search-input auto-submit'}, :can => true  },
     {:name => 'Created  ', :tag => :created_at,        :options => params[:created_at], :html => {include_blank: true, class:'search-input auto-submit'}, :can => true , :type => 'date'}
    ]
  end

  # Sort Column
  def accounts_sort_column
    acceptable_cols = %w("accounts.name accounts.description")
    acceptable_cols.include?(params[:sort]) ? params[:sort] : "accounts.name"
  end

  # Sort Method
  def accounts_sort(column, title = nil)
    title ||= column.titleize
    css_class = column == accounts_sort_column ? "current #{desc_sort_direction}" : nil
    direction = column == accounts_sort_column && desc_sort_direction == "desc" ? "asc" : "desc"
    link_to title, {:sort => column, :direction => direction, :search => params[:search], :per_page => params[:per_page]}, {:class => css_class, :title => "Sort"}
  end

end


