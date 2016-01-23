class InitController < ApplicationController
  def index
    if session[:invalid_loc].nil? or session[:invalid_loc] == true
      store_geocode(:lat=>request.location.latitude,:lon=>request.location.longitude)
    end
    
    if params[:lat].blank? == false and params[:lon].blank? == false
      result = Geocoder.search(params[:lat]+','+params[:lon])[0]
      if result.nil?
        render :text=>'geocoder search failed'
        return
      end
      
      store_geocode(:result=>result)
      
    end
    render :text=>'success'
  end
  
  def time_zone   
    offset_seconds = params[:offset_minutes].to_i * 60
    time_zone = ActiveSupport::TimeZone[offset_seconds]
    time_zone = ActiveSupport::TimeZone["UTC"] unless time_zone
    session[:time_zone_name] = time_zone.name if time_zone
    
    render :text=>'success'
  end
end
