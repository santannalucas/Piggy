module ToolsHelper

  # Images Search Fields
  def import_files_search
    [{:name => 'Display:',     :tag => :per_page,            :options => options_for_select(per_page_options, params[:per_page]),                   :html => {class:'search-input auto-submit'}, :can => true  }]
  end

  # Sort Column
  def import_sort_column
    acceptable_cols = %w(import_files.name)
    acceptable_cols.include?(params[:sort]) ? params[:sort] : "import_files.name"
  end

  # Sort Method
  def import_sort(column, title = nil)
    title ||= column.titleize
    css_class = column == import_sort_column ? "current #{desc_sort_direction}" : nil
    direction = column == import_sort_column && desc_sort_direction == "desc" ? "asc" : "desc"
    link_to title, {:sort => column, :direction => direction, :search => params[:search], :per_page => params[:per_page]}, {:class => css_class, :title => "Sort"}
  end

end
