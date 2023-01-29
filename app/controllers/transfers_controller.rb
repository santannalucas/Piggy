class TransfersController < ApplicationController
  include TransactionsHelper
  include ApplicationHelper
  require 'will_paginate/array'

  # Routed Action - Create Role
  def create
    # Check Access
    created_at = params[:transfer][:created_at]
    sub_id = SubCategory.where(name:'Transfers').first.id
    @transfer = Transfer.new(transfer_params)
    @transfer.from_bank_account.assign_attributes(sub_category_id:sub_id, transaction_type_id: 3, created_at:created_at, description:params[:description],transfer:true)
    @transfer.to_bank_account.assign_attributes(sub_category_id:sub_id, transaction_type_id: 2, created_at:created_at, description:params[:description],transfer:true)
    if @transfer.save
        redirect_link = transactions_path(:bank_account_id => @transfer.from_bank_account.bank_account.id)
        flash[:notice] = 'Transaction successfully created.'
      else
        # Save Failed
        error = 'transfer'
        redirect_link = transactions_path(bank_account_id: params[:from_bank_account],
                                          transfer:transfer_params,
                                          desc:params[:description],
                                          transfer_error:error)
        flash[:error] = errors_to_string(@transfer.errors)
      end
      redirect_to redirect_link
  end

  # Routed Action - Create Role
  def update
    # Check Access
    created_at = params[:transfer][:created_at]
    @transfer = Transfer.find(params[:id])
    @transfer.assign_attributes(transfer_params)
    @transfer.from_bank_account.assign_attributes(transaction_type_id: 3, created_at:created_at, description:params[:description])
    @transfer.to_bank_account.assign_attributes(transaction_type_id: 2, created_at:created_at, description:params[:description])
    if @transfer.save
      redirect_link = transactions_path(:bank_account_id => @transfer.from_bank_account.bank_account.id)
      flash[:notice] = 'Transaction successfully updated.'
    else
      # Save Failed
      error = 'transfer'
      redirect_link = transactions_path(bank_account_id: params[:from_bank_account],
                                        transfer:transfer_params,
                                        desc:params[:description],
                                        transfer_error:error)
      flash[:error] = errors_to_string(@transfer.errors)
    end
    redirect_to redirect_link
  end

  def destroy
    @transfer = Transfer.find(params[:id])
    if @transfer.destroy
      flash[:notice] = 'Transaction successfully deleted.'
    else
      flash[:error] = errors_to_string(@transfer.errors)
    end
    redirect_to transactions_path(:bank_account_id => params[:bank_account_id])
  end



end
