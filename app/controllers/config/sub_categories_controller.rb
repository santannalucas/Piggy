class Config::SubCategoriesController < ApplicationController
  # Helpers and Modules
  include CategoriesHelper
  require 'will_paginate/array'

  ### Sub-Category(ies) - Routes / Controller Methods

  # Routed Action - Sub-Categories Index
  def index
    # Check Access and Log
    if can?(:category,:search)  # Index
      get_search_defaults(15)
      access_log('Search Sub-Categories', 'Search')
      # Load Category(ies)
      @categories = @current_user.categories.order(:name)
      @category = @categories.where(id:params[:category_id]).try(:first)
      # Form for New / Edit Sub-Category
      @sub_category_new = @category.present? ? @category.sub_categories.new : @current_user.sub_categories.new
      @sub_category_edit = SubCategory.find(params[:error_id]).assign_attributes(bank_account_params) if params[:error_id].present?
      # Filtering and sort Users
      @sub_categories = @current_user.sub_categories.filtering(params.slice(:category_id,:all_words_search, :sentence_search))
      @total_sub_categories = @sub_categories.count
      @sub_categories = @sub_categories.order(cat_sort_column + " " + asc_sort_direction).paginate(:page => params[:page], :per_page => params[:per_page]) if @sub_categories.present?
    else
      # Failed Access
      failed_access('Search Sub-Categories', 'Search')
    end
  end

  def create
    if can?(:category,:create)
      @sub_category = @current_user.sub_categories.new(sub_category_params)
      if @sub_category.save
        # Recreate Custom and CRUD Rules
        redirect_link = sub_categories_path(category_id:@sub_category.category.id)
        flash[:notice] = 'Category successfully created.'
      else
        # Save Failed
        redirect_link = sub_categories_path(sub_category:sub_category_params, errors:'error')
        flash[:error] = errors_to_string(@sub_category.errors)
      end
      redirect_to redirect_link
    else
      # Failed Access
      failed_access('Create Category', 'Create')
    end
  end

  def update
    @sub_category = SubCategory.find(params[:id])
    if can?(:category,:update)
      if @sub_category.update(sub_category_params)
        # Recreate Custom and CRUD Rules
        redirect_link = sub_categories_path(updated:@sub_category.id)
        flash[:notice] = 'Sub-Category successfully updated.'
      else
        # Save Failed
        redirect_link = sub_categories_path(sub_category:sub_category_params, error_id:@sub_category.id)
        flash[:error] = errors_to_string(@sub_category.errors)
      end
      redirect_to redirect_link
    else
      # Failed Access
      failed_access('Create Sub-Category', 'Create', @sub_category.name)
    end
  end

  # Routed Action - Destroy Account
  def destroy
    # Get SubCategory
    @sub_category = SubCategory.find(params[:id])
    sub_category_name = @sub_category.name
    if can?(:category, :delete)
      # Save Attempt and Log
      if @sub_category.destroy
        access_log("Sub-Category", 'Delete', sub_category_name)
        flash[:notice] = "Sub-Category successfully deleted."
        return_url = sub_categories_path
      else
        # Save Failed
        flash[:error] = errors_to_string(@sub_category.errors)
        return_url = sub_categories_path
      end
      redirect_to return_url
    else
      # Failed Access
      failed_access("Delete Sub-Category", 'Delete', @sub_category.name)
    end
  end

  private # Controller Private Methods

  # Access Log
  def access_log(action, rule, details = nil)
    AccessLog.create(user_id: @current_user.id , role_id: @current_user.role.id, workspace_id: Workspace.where(name:"Categories").first.id, action:action, access_rule:rule, details:details)
  end

  # Account Secure Params
  def sub_category_params
    params.require(:sub_category).permit(:name, :category_id)
  end

end