module ApplicationHelper
  def javascript(*files)
      content_for(:head) { javascript_include_tag(*files) }
  end
  
  def hashtags(string)
    scanned_tags = Array.new
    tags = string.scan(/^#\w+/)
    tags.each {|tag| scanned_tags << tag if tag.strip.match(/#\d+$/).nil? }
    tags = string.scan(/(?<= )#\w+/)
    tags.each {|tag| scanned_tags << tag if tag.strip.match(/#\d+$/).nil? }
    scanned_tags
  end

  def replies(string)
    tags = string.scan(/(?<= )@[A-Za-z]+/)
    scanned_tags = Array.new
    tags.each {|tag| scanned_tags << tag if tag.strip.match(/#\d+$/).nil? }
    scanned_tags
  end
  
  def auto_link_hashtags(string)
    tags = hashtags(string)
    return string if tags.size == 0
    replacements = Hash.new
    tags.each {|tag| replacements[tag] = link_to(tag,posts_path(:tag=>tag)) }
    t = string.gsub(/#{tags.join('|')}/, replacements).html_safe
  end
  
  def auto_links(string)
    string = auto_link_hashtags(string)
    auto_link(string) {|link_text|
      if link_text.length>=30
        link_text[0,11]+'...'+link_text[link_text.length-6,link_text.length-1]
      else
        link_text
      end
    }
    
  end
  
  def display_local_time(t)
    return '' unless t
    
    time_zone = ActiveSupport::TimeZone[session[:time_zone_name]] if session[:time_zone_name]
    Time.zone = time_zone.name if time_zone
    
    return t.in_time_zone.strftime('%Y-%m-%d @ %l:%M%P')
  end
  
  def resource_owner(access_token)
    Oauth2Token.find_by_token(access_token).user
  end
  
  def valid_device_key?(device_key)
    encrypted_device_key = Oauth2Token.find_by_token(params[:access_token]).encrypted_device_key
    return false if encrypted_device_key.blank?
    
    bcrypt   = ::BCrypt::Password.new(encrypted_device_key)
    device_key = ::BCrypt::Engine.hash_secret("#{device_key}", bcrypt.salt)
    Devise.secure_compare(device_key, encrypted_device_key)
  end
  
  def validate_access_token
    unless params[:access_token].blank?
      if params[:device_key].blank? or valid_device_key?(params[:device_key]) == false
        if request.format.json? 
          render :json => 'Invalid device key', :status => :unauthorized
        else
          raise 'Invalid device key'
        end
        return
      end
    end
  end
  
  def mobile_device?
    request.user_agent =~ /Mobile|webOS/
  end
  
  def after_sign_in_path_for(resource)
   users_sign_out_path
  end
  
end
