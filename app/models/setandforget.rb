class Setandforget < ActiveRecord::Base
  belongs_to :user


  def self.search_params(params={})
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

  def self.with_params(params={})
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

  def self.save_search_params(params={})
    return [nil] if params.blank? || params[:search].blank?
    p = params[:search].dup
    return p
  end
end
