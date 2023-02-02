module CategoriesHelper

  # Images Search Fields
  def categories_search
    [
      {:name => 'Display',   :tag => :per_page,          :options => options_for_select(per_page_options, params[:per_page]),                   :html => {class:'search-input auto-submit'}, :can => true  }
    ]
  end

  # Images Search Fields
  def sub_categories_search
    [
      {:name => 'Display',    :tag => :per_page,          :options => options_for_select(per_page_options, params[:per_page]),                   :html => {class:'search-input auto-submit'}, :can => true  },
      {:name => 'Created  ',  :tag => :created_at,        :options => params[:created_at], :html => {include_blank: true, class:'search-input auto-submit'}, :can => true , :type => 'date'},
      {:name => 'Category  ', :tag => :category_id,        :options => options_for_select(@categories.collect{|x| [x.name,x.id]},params[:category_id]), :html => {include_blank: true, class:'search-input auto-submit'}, :can => true}
    ]
  end

  def category_types_options
    [['All',1],['Deposits',2],['Expenses',3]]
  end

  # Sort Column
  def sub_cat_sort_column
    acceptable_cols = %w("categories.name sub_categories.name")
    acceptable_cols.include?(params[:sort]) ? params[:sort] : "sub_categories.name"
  end

  # Sort Column
  def cat_sort_column
    acceptable_cols = %w("categories.name categories.category_type")
    acceptable_cols.include?(params[:sort]) ? params[:sort] : "categories.name"
  end

  # Sort Method
  def cat_sort(column, title = nil)
    title ||= column.titleize
    css_class = column == cat_sort_column ? "current #{desc_sort_direction}" : nil
    direction = column == cat_sort_column && desc_sort_direction == "desc" ? "asc" : "desc"
    link_to title, {:sort => column, :direction => direction, :search => params[:search], :per_page => params[:per_page]}, {:class => css_class, :title => "Sort"}
  end

  def sub_cat_sort(column, title = nil)
    title ||= column.titleize
    css_class = column == sub_cat_sort_column ? "current #{desc_sort_direction}" : nil
    direction = column == sub_cat_sort_column && desc_sort_direction == "desc" ? "asc" : "desc"
    link_to title, {:sort => column, :direction => direction, :search => params[:search], :per_page => params[:per_page]}, {:class => css_class, :title => "Sort"}
  end
end


