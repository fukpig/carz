class SetandforgetController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html

  def index
    set_default
    @searchs = current_user.setandforget
    set_start_variables
    respond_with(@searchs)
  end

  def get_series
    set_default
    set_series(params[:search_make])
    render layout:false
  end

  def get_models
    set_default
    set_models(params[:search_series])
    render layout:false
  end


  #TO-DO CHANGE THIS CODE(FAT)
  def search
    if params[:save]
      id = 'new' 
      id = params[:search]['id'] if !params[:search]['id'].nil? && !params[:search]['id'].empty?
      remove_id_param
      search_json = save_search_params(params).to_json
      snf = current_user.setandforget.where('search_params = ?', search_json).first
      if snf.nil?
        if id != 'new'
          snf = Setandforget.find(id)
          snf.update_attributes(:search_params => search_json)
          redirect_to setandforget_index_path
        else
          snf = Setandforget.new(:search_params => search_json, :user_id => current_user.id)
          if snf.save
            redirect_to setandforget_index_path
          end
        end
      else 
        redirect_to setandforget_index_path
      end
    else
      set_start_variables
      set_default
      set_series(params["search"]["make"])
      set_models(params["search"]["series"])
      set_id
      remove_id_param

      with_params = with_params(params)
      @cars = Car.search "", :conditions => search_params(params), :with => with_params, :per_page => 500

    end
  end

  def show
    respond_with(@car)
  end


  def new
  end

  def edit
    snf = Setandforget.find(params[:id])
    params["search"] = JSON.parse snf.search_params
    url_params = Hash.new
    url_params["search"] = Hash.new
    params["search"].each do |k,v|
      url_params["search"][k] = v
    end
    url_params["search"]["id"] = snf.id

    redirect_to set_and_forget_search_path(url_params)
  end

  def create
  end

  def update
    snf = Setandforget.find(params[:id])
    snf.update_attributes(:search_params => search_params(params).to_json)
    redirect_to setandforget_index_path
  end
  
  def edit_status
  end
  
  def set_status
	  @car.update(status_params)
	  respond_with(@car)
  end

  def destroy
    snf = Setandforget.find(params[:id])
    snf.destroy
    redirect_to setandforget_index_path
  end

  private

  def set_id
    @id = isset_id_in_params? ? params[:search]['id'] : 'new'
  end

  def set_makes
    @makes = CarsMake.get_makes
  end

  def set_series(make)
    @series = CarsSeries.get_series(make)
  end

  def set_models(series)
    @models = CarsModel.get_models(series)
  end

  def set_options
    @options = SearchOption.get_options
  end

  def set_start_variables
    set_makes
    set_options
    set_id
  end


  def isset_id_in_params?
    return false if params[:search].nil?
    return true if !params[:search]['id'].nil? && !params[:search]['id'].empty?
  end

  def remove_id_param()
    params[:search].delete :id
  end

  def set_default()
    @make_default = ''
    @make_default = params[:search][:make] if !params[:search].nil?

    @series_defaults = Array.new()
    get_param = params[:search][:series] if !params[:search].nil?
    if !get_param.nil?
      get_param.each do |s|
        @series_defaults << s
      end
    end
    @models_defaults = Array.new()
    get_param = params[:search][:model] if !params[:search].nil?
    if !get_param.nil?
      get_param.each do |m|
        @models_defaults << m
      end
    end
  end

  def get_series_params(params)

  end

  def get_series_priv(make)
    series = CarsSeries.where('make_id = ?', make.id)
    info = Array.new
    info << ['all', 'all models']
    info << ['no_series', 'without series']
    series.each do |s|
      array = [s.name, s.name]
      info << array
    end
    return info
  end

  def get_models_priv(make)
    @models = CarsModels.where('make_id = ?', make.id)
  end

  def get_models_search(make)
    @models = CarsModels.where('make_id = ?', make.id)
  end

  def search_params(params={})
    return [nil] if params.blank? || params[:search].blank?
    p = params[:search].dup
    info = Hash.new
    p.each do |k,v|
      if !k.to_s.include?("_from") && !k.to_s.include?("_to")
        info[k] = v
      end
    end
    return info
  end

  def save_search_params(params={})
    return [nil] if params.blank? || params[:search].blank?
    p = params[:search].dup
    return p
  end

  def with_params(params={})
    return {} if params.blank? || params[:search].blank?
    info = Hash.new
    params[:search].each do |k, v|
      if k.to_s.include? "_from"
        param_f = v
        param_f = 0 if param_f.empty?
            
        param_name = k.to_s.gsub("_from", "")

        param_t = params[:search][param_name+"_to"]
        param_t = 99999 if param_t.empty?
        info[param_name] = param_f.to_i..param_t.to_i
      end
    end
    return info
  end


end
