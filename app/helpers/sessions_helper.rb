module SessionsHelper
  
  def store_geocode(arg)
    if arg.has_key?(:lat)
      result = Geocoder.search(arg[:lat].to_s+','+arg[:lon].to_s).first
    elsif arg.has_key?(:city)
      result = Geocoder.search(arg[:city]).first
    elsif arg.has_key?(:result)
      result = arg[:result]
    elsif arg.has_key?(:loc_data)
      data = arg[:loc_data]
      session[:invalid_loc] = false
      session[:lat] = data[:latitude]
      session[:lon] = data[:longitude]
      session[:city] = data[:city]
      session[:province] = data[:province]
      session[:country] = data[:country]
      session[:postal_code] = data[:postal_code]
     
      session[:location_id] = data[:location].id
      session[:location] = data[:location].common_name
      return
    else
      return
    end
      
    if result.nil?
      session[:invalid_loc] = true
    elsif (result.city.blank? and result.town.blank?) or result.province.blank?
      session[:invalid_loc] = true
    else
      session[:invalid_loc] = false
      session[:lat] = result.latitude
      session[:lon] = result.longitude
      
      
      session[:city] = (result.city.blank?) ? result.town : result.city
      session[:province] = result.state
      session[:country] = result.country  
      session[:postal_code] = result.postal_code
    end
  end
  
end

