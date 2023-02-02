module BankAccountsHelper

  # Images Search Fields
  def bank_accounts_search
    [
      {:name => 'Display',   :tag => :per_page,          :options => options_for_select(per_page_options, params[:per_page]),                   :html => {class:'search-input auto-submit'}, :can => true  },
      {:name => 'Created  ', :tag => :created_at,        :options => params[:created_at], :html => {include_blank: true, class:'search-input auto-submit'}, :can => true , :type => 'date'},
      {:name => 'Currency:', :tag => :currency_id,       :options => options_for_select( Currency.order(:name).collect {|x| [x.name.titleize,x.id]}, params[:currency_]), :html => {class:'multiple_select', multiple:true}, :can => true  }
    ]
  end

  def account_types_options
    [['Cash',1],['Everyday',2], ['Savings',3], ['Investment',4], ['Credit Card',5]]
  end

  # Sort Column
  def bank_acc_sort_column
    acceptable_cols = %w("bank_accounts.name bank_accounts.number bank_accounts.description bank_accounts.created_at bank_accounts.currency_id")
    acceptable_cols.include?(params[:sort]) ? params[:sort] : "bank_accounts.name"
  end

  # Sort Method
  def bank_acc_sort(column, title = nil)
    title ||= column.titleize
    css_class = column == bank_acc_sort_column ? "current #{desc_sort_direction}" : nil
    direction = column == bank_acc_sort_column && desc_sort_direction == "desc" ? "asc" : "desc"
    link_to title, bank_search_params.merge(:sort => column, :direction => direction), {:class => css_class, :title => "Sort"}
  end

  def bank_search_params
    { :search => params[:search], :tag_filter => params[:tag_filter], :per_page => params[:per_page], :image_type_id => params[:image_type_id]}
  end
end


