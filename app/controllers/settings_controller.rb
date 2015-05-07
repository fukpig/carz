class SettingsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_option, only: [:edit_search_option, :delete_search_option, :update_search_option, :show_search_option]
  respond_to :html

  def show_search_options
    @options = SearchOption.all
  end

  def show_search_option
    respond_with(@option)
  end

  def new_search_option
    @option = SearchOption.new
    respond_with(@option)
  end

  def create_search_option
    @option = SearchOption.new(search_option_params)
    @option.save
    redirect_to search_options_path
  end

  def edit_search_option

  end

  def update_search_option
    @option.update(search_option_params)
    redirect_to search_options_path
  end

  def delete_search_option
    @option.destroy
    redirect_to search_options_path
  end


  private
    def set_option
      @option = SearchOption.find(params[:id])
    end


    def search_option_params
      params.require(:search_option).permit(:option_name, :values, :field_type, :option_field)
    end
end
