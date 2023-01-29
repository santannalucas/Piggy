module DashboardHelper

  def next_year_month(month,year,account_id)
    dashboard_path(:year => month.to_i == 12 ? year.to_i + 1 : year, :month => month.to_i == 12 ? 1 : month.to_i + 1,:bank_account_id => account_id)
  end

  def previous_year_month(month,year,account_id)
    dashboard_path(:year => month.to_i == 1 ? year.to_i - 1 : year, :month => month.to_i == 1 ? 12 : month.to_i - 1,:bank_account_id => account_id)
  end



end



