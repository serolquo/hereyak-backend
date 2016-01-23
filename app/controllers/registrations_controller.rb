class RegistrationsController < Devise::RegistrationsController
  skip_before_filter :verify_authenticity_token, :only => :create

  #overide default devise destroy to use soft_delete, the rest of the code is the same as devise's version
  def destroy
    resource.soft_delete
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message :notice, :destroyed if is_navigational_format?
    respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }
  end
  
  def create
    respond_to do |format|  
      format.html { 
        super 
      }
      format.json {
        begin
          client_application = ClientApplication.find_by_key! params[:client_id]
          build_resource params[:user]
          resource.skip_confirmation!
          if resource.save
            token = Oauth2Token.create :client_application=>client_application, :user=>resource, :scope=>nil, :device_key=>params[:device_key]
            render :json=>{:access_token=>token.token, :username=>resource.username}, status: :created
          else
            render :json => resource.errors, :status => :unprocessable_entity
          end
        rescue
          render :json => 'Bad parameters were passed', :status => :unprocessable_entity
        end
      }
    end
  end
end
