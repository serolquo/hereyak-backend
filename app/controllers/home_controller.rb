class HomeController < ApplicationController
  def index
    redirect_to posts_path and return if user_signed_in? and !session[:city].blank?
    redirect_to location_home_index_path and return if user_signed_in? and (session[:invalid_loc].nil? or session[:invalid_loc] == true)
  end
    
  def location
    render 'put_location'
  end
  
  def put_location
    results = Geocoder.search(params[:location])
    if results.nil?
      flash.now[:notice] = "The location you entered is invalid. Please try again."
      return
    end
    valid_result = nil
    results.each {|result| 
      if result.city.blank? == false or result.town.blank? == false
        valid_result ||= result 
        valid_result = result if ['school','college','university'].include? result.data['type']
      end
    }
    
    if !valid_result.nil?
      store_geocode(:result=>valid_result)
      redirect_to posts_path(:lat=>session[:lat],:lon=>session[:lon])
      return
    end
    
    
    #cannot find a valid city
    flash.now[:notice] = "Please enter a valid location."
    return
    
  end
  
  def contact
    render 'send_contact_form'
  end
  
  def send_contact_form
    if params[:message].blank?
      flash.now[:notice] = "Please do not leave the message field blank."
      return
    end
    
    GeneralMailer.contact_us_form(params).deliver
    @message_sent = true
      
  end
  
end
