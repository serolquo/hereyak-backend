class SessionsController < Devise::SessionsController

  #overide default devise create to return token for json requests
  respond_to :html, :json
  def create
    respond_to do |format|  
      format.html { 
        super 
      }
      format.json {
        begin
          #auth_options[:recall] = "failed"
          warden.custom_failure!
          self.resource = warden.authenticate!(:scope => resource_name, :recall => "failed")
          #token = resource.tokens.where('authorized_at is not NULL').where(:type=>'Oauth2Token',:invalidated_at=>nil).first
          #(token.device_key=params[:device_key]) unless params[:device_key].blank?
          
          client_application = ClientApplication.find_by_key! params[:client_id]
          token = Oauth2Token.create :client_application=>client_application, :user=>resource, :scope=>nil, :device_key=>params[:device_key]

          sign_in(resource_name, resource)
          render :json=>{:access_token=>token.token, :username=>resource.username}, status: :created
        rescue
          render :json => 'Invalid credentials', :status => :unprocessable_entity
        end
      }
    end
  end
  
  def failed
    logger.debug "in the failed function"
    render :json => 'Invalid credentials', :status => :unprocessable_entity
  end
end
