module SchedulersHelper

  # Images Search Fields
  def schedulers_search
    [
      {:name => 'Display',       :tag => :per_page,            :options => options_for_select(per_page_options, params[:per_page]),                   :html => {class:'search-input auto-submit'}, :can => true  },
      {:name => 'Status:',       :tag => :completed,           :options => options_for_select([['Active',false],['Completed',true],['All', nil]],params[:completed]), :html => {class:'search-input auto-submit'}, :can => true },
      {:name => 'Category:',     :tag => :category_id,         :options => options_for_select(SubCategory.all.collect{ |x| [x.name,x.id]}, params[:category_id]), :html => {class:'multiple_select', multiple:true}, :can => true  },
      {:name => 'Bank Account:', :tag => :bank_account_id,     :options => options_for_select(@current_user.bank_accounts.order(:name).collect{|x|[x.name,x.id]}, params[:bank_account_id]), :html => {class:'multiple_select', multiple:true}, :can => true  },
      {:name => 'Account:',      :tag => :account_id,          :options => options_for_select(@current_user.accounts.order(:name).collect{|x|[x.name,x.id]}, params[:account_id]), :html => {class:'multiple_select', multiple:true}, :can => true  },
      {:name => 'Type:',         :tag => :transaction_type_id, :options => options_for_select( TransactionType.order(:name).collect {|x| [x.name.titleize,x.id]}, params[:transaction_type_id]), :html => {class:'multiple_select', multiple:true}, :can => true  }
    ]
  end

  def scheduler_items_search
    [
      {:name => 'Display',   :tag => :per_page,          :options => options_for_select(per_page_options, params[:per_page]),                   :html => {class:'search-input auto-submit'}, :can => true  }
    ]
  end

  # Sort Column
  def schedulers_sort_column
    acceptable_cols = %w("schedulers.id bank_accounts.name accounts.name scheduler_items.created_at scheduler_types.name")
    acceptable_cols.include?(params[:sort]) ? params[:sort] : "schedulers.created_at"
  end

  # Sort Method
  def schedulers_sort(column, title = nil)
    title ||= column.titleize
    css_class = column == schedulers_sort_column ? "current #{desc_sort_direction}" : nil
    direction = column == schedulers_sort_column && desc_sort_direction == "desc" ? "asc" : "desc"
    link_to title, schedulers_search_params.merge(:sort => column, :direction => direction), {:class => css_class, :title => "Sort"}
  end

  def schedulers_search_params
    {
      :search => params[:search],
      :account_id => params[:account_id],
      :per_page => params[:per_page],
      :bank_account_id => params[:bank_account_id],
      :scheduler_type_id => params[:scheduler_type_id]
    }
  end
end


