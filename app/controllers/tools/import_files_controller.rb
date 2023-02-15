class Tools::ImportFilesController < ApplicationController

  include ToolsHelper
  require 'csv'

  def index
    get_search_defaults(15)
    @imports = ImportFile.all
    @total_imports = @imports.count
    @imports = @imports.order(import_sort_column + " " + desc_sort_direction).paginate(:page => params[:page], :per_page => params[:per_page]) if @imports.present?
  end

  def new
    @import = ImportFile.find(params[:id])
  end

  def create
    # Check if file was provided.
    if params[:file]
      file = File.open(params[:file])
      # Handling if file not CSV or out of format
      begin
        result = []
        row_count = 1
        # Parsing/Importing Rows
        CSV.foreach(file.path).each do |row|
          result << Importer.parse_row(row,row_count) unless row_count == 1
          row_count += 1
        end
        result = result.join(' / ')
      rescue
        # If cannot read file
        result = "<span style='color:red'>Could not read from file, please upload CSV file only.</span>"
      end
    else
      # File not provided
      result = "File not Found"
    end
    flash[:notice] = result
    redirect_to people_path
  end

  def destroy
    @person = Person.find(params[:id])
    flash[:notice] = 'Person Deleted.' if @person.delete
    redirect_to root_path
  end

end
