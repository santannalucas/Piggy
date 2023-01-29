module TransactionsHelper

  # Images Search Fields
  def transactions_search
    [
      {:name => 'Display:',     :tag => :per_page,            :options => options_for_select(per_page_options, params[:per_page]),                   :html => {class:'search-input'}, :can => true  },
      {:name => 'Category:',   :tag => :category_id,         :options => options_for_select(SubCategory.all.collect{ |x| [x.name,x.id]}, params[:category_id]), :html => {class:'multiple_select', multiple:true}, :can => true  },
      {:name => 'Account:',    :tag => :account_id,          :options => options_for_select(@current_user.accounts.order(:name).collect{|x|[x.name,x.id]}, params[:account_id]), :html => {class:'multiple_select', multiple:true}, :can => true  },
      {:name => 'Type:',       :tag => :transaction_type_id, :options => options_for_select( TransactionType.order(:name).collect {|x| [x.name.titleize,x.id]}, params[:transaction_type_id]), :html => {class:'multiple_select', multiple:true}, :can => true  },
      {:name => 'Period:',      :tag => :period,              :options => options_for_select(search_date_periods, params[:period]),  :html => {class:'search-input'}, :can => true  },
      {:name => 'Date:',      :tag => :start_date,          :options => params[:start_date], :html => {include_blank: true, class:'search-date'}, :tag_end => :end_date, :options_end => params[:end_date],  :html_end => {include_blank: true, class:'search-date end'}, :can => true , :type => 'custom'},
    ]
  end

  # Sort Column
  def transactions_sort_column
    acceptable_cols = %w(accounts.name categories.name transactions.transaction_type_id transactions.created_at)
    acceptable_cols.include?(params[:sort]) ? params[:sort] : "transactions.created_at"
  end

  # Sort Method
  def transaction_sort(column, title = nil)
    title ||= column.titleize
    css_class = column == transactions_sort_column ? "current #{desc_sort_direction}" : nil
    direction = column == transactions_sort_column && desc_sort_direction == "desc" ? "asc" : "desc"
    link_to title, {:sort => column, :direction => direction, :search => params[:search], :bank_account_id => params[:bank_account_id], :transaction_type_id => params[:transaction_type_id], :per_page => params[:per_page], :account_id => params[:account_id_id], :period => params[:period], :sub_category_id => params[:sub_category_id]}, {:class => css_class, :title => "Sort"}
  end

end


