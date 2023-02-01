class Config::CategoriesController < ApplicationController
  # Helpers and Modules
  include CategoriesHelper
  require 'will_paginate/array'

  ### Category(ies) - Routes / Controller Methods

  # Routed Action - Categories Index
  def index
    # Check Access and Log
    if can?(:category,:search)  # Index
      get_search_defaults(15)
      access_log('Search Categories', 'Search')
      # Form for New Category
      @category = @current_user.categories.new
      @edit_category = Category.find(params[:error_id]) if params[:error_id].present?
      @edit_category.assign_attributes(bank_account_params) if @edit_category.present?
      # Filtering and sort Users
      @categories = @current_user.categories.filtering(params.slice(:all_words_search, :sentence_search))
      @total_categories = @categories.count
      @categories = @categories.order(cat_sort_column + " " + asc_sort_direction).paginate(:page => params[:page], :per_page => params[:per_page]) if @categories.present?
    else
      # Failed Access
      failed_access('Search Categories', 'Search')
    end
  end

  def create
    if can?(:category,:create)
      @category = @current_user.categories.new(category_params)
      if @category.save
        # Recreate Custom and CRUD Rules
        redirect_link = categories_path
        flash[:notice] = 'Category successfully created.'
      else
        # Save Failed
        redirect_link = categories_path(category:category_params, errors:'error')
        flash[:error] = errors_to_string(@category.errors)
      end
      redirect_to redirect_link
    else
      # Failed Access
      failed_access('Create Category', 'Create')
    end
  end

  def update
    @category = Category.find(params[:id])
    if can?(:category,:update)
      if @category.update(category_params)
        # Recreate Custom and CRUD Rules
        redirect_link = categories_path(updated:@category.id)
        flash[:notice] = 'Category successfully updated.'
      else
        # Save Failed
        redirect_link = categories_path(category:category_params, error_id:@category.id)
        flash[:error] = errors_to_string(@category.errors)
      end
      redirect_to redirect_link
    else
      # Failed Access
      failed_access('Create Category', 'Create', @category.name)
    end
  end

  def destroy
    @category = Category.find(params[:id])
    if can?(:category,:delete)
      if @category.destroy
        # Recreate Custom and CRUD Rules
        flash[:notice] = 'Category successfully deleted.'
      else
        # Save Failed
        flash[:error] = errors_to_string(@category.errors)
      end
      redirect_to categories_path
    else
      # Failed Access
      failed_access('Delete Category', 'Delete', @category.name)
    end
  end

  private # Controller Private Methods

  # Access Log
  def access_log(action, rule, details = nil)
    AccessLog.create(user_id: @current_user.id , role_id: @current_user.role.id, workspace_id: Workspace.where(name:"Categories").first.id, action:action, access_rule:rule, details:details)
  end

  # Account Secure Params
  def category_params
    params.require(:category).permit(:name, :category_type)
  end

end