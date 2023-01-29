module CurrenciesHelper

  # Images Search Fields
  def currencies_search
    [
      {:name => 'Display',   :tag => :per_page,          :options => options_for_select(per_page_options, params[:per_page]),                   :html => {class:'search-input'}, :can => true  },
      {:name => 'Created  ', :tag => :created_at,        :options => params[:created_at], :html => {include_blank: true, class:'search-input'}, :can => true , :type => 'date'}
    ]
  end

  # Sort Column
  def currencies_sort_column
    acceptable_cols = %w("currencies.name currencies.code currencies.rate")
    acceptable_cols.include?(params[:sort]) ? params[:sort] : "currencies.name"
  end

  # Sort Method
  def currencies_sort(column, title = nil)
    title ||= column.titleize
    css_class = column == currencies_sort_column ? "current #{desc_sort_direction}" : nil
    direction = column == currencies_sort_column && desc_sort_direction == "desc" ? "asc" : "desc"
    link_to title, {:sort => column, :direction => direction, :search => params[:search], :per_page => params[:per_page]}, {:class => css_class, :title => "Sort"}
  end


end


