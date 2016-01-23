class PostsController < ApplicationController
  #before_filter :authenticate_user!, :except => [:index, :show]
  oauthenticate
  before_filter :check_required_params, :except => [:update, :destroy, :show]
  skip_before_filter :verify_authenticity_token, :only => :create
  
  append_before_filter :validate_access_token
  # GET /posts
  # GET /posts.json
  def index
    
    conditions = "reply_to_post is NULL"
    if !params[:last_message_received].blank? and params[:last_message_received].to_i > 0
      conditions = conditions + " AND id > #{params[:last_message_received].to_i}"
    end
    

    center_point = [params[:lat], params[:lon]]
    box = Geocoder::Calculations.bounding_box(center_point, 1) #1km box for now
    
    if params[:tag].blank?
      @posts = Post.within_bounding_box(box).where(conditions).order("created_at DESC").page params[:page]
    else
      @posts = TagName.find_by_name(params[:tag]).posts.within_bounding_box(box).where(conditions).order("created_at DESC").page params[:page]
    end
    
    @posts = Post.where('id = 1').page params[:page] if @posts.size == 0 and (params[:last_message_received].blank? or params[:last_message_received].to_i == 0)

    only = [:id,:content,:post_date,:user_id]    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @posts.to_json(:include => { :user => { :only => :username } }, :only =>only ) }
      format.js
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show  
    @post = Post.find(params[:id])
    
    @replies = Kaminari.paginate_array(@post.all_replies.order("created_at DESC")).page params[:page]
      
    respond_to do |format|
      format.html # show.html.erb
      format.json { 
        @replies << @post
        render json: @replies.to_json(:include => { :user => { :only => :username } }, :only =>[:id,:content,:post_date,:user_id] )
      }
      format.js
    end
  end

  # GET /posts/new
  # GET /posts/new.json
  def new 
    @post = Post.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @post }
    end
  end
  
  # GET /posts/1/reply
  def reply    
    if session[:invalid_loc].nil? or session[:invalid_loc] == true
      redirect_to posts_path, notice: 'You cannot post because we cannot obtain your location.'
      return
    end
    parent_post = Post.find(params[:id])
    @post = parent_post.replies.new
    
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /posts/1/edit
  def edit
    #disable edit for now
    redirect_to posts_path
    return
    
    if user_signed_in? == false
      deny_access
      return
    end
    @post = Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.json
  def create
    if params[:post].nil? or params[:post].blank?
      if request.format.json? 
        render :json => 'The post is missing', :status => :unprocessable_entity
      else
        raise 'The post is missing'
      end
      return
    end
    if params[:post][:reply_to_post].blank? == false  
      parent_post = Post.find(params[:post][:reply_to_post])
      
      unless (parent_post.parent_post.nil?) #restrict replies to 1 level for now
        if request.format.json? 
          render :json => 'Cannot reply to a reply', :status => :unprocessable_entity
        else
          raise 'Cannot reply to a reply'
        end
        return
      end
      
      @post = parent_post.replies.new(params[:post])
    else
      @post = Post.new(params[:post])
    end
    
    @post.content = @post.content.squish

    @post.latitude = params[:lat]
    @post.longitude = params[:lon]
   
    current_user = resource_owner(request.env["HTTP_AUTHORIZATION"][/^(Bearer|OAuth|Token) (token=)?([^\s]*)$/, 3]) if current_user.nil?
        
    @post.user_id = current_user.id
    @post.post_date = DateTime.now
    
    @post.tag_names << TagName.find_or_create_many_tag_names(hashtags(@post.content))

    respond_to do |format|
      if @post.save
        format.html { 
          redirect_to posts_path and return if @post.parent_post.nil?
          redirect_to url_for @post.root_parent and return
        }
        format.json { render :json => 'success', status: :created, location: @post }
      else
        format.html { render action: "new" } if parent_post.nil?
        format.html { render action: "reply" } if !parent_post.nil?
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.json
  def update
    #disable edit for now
    redirect_to posts_path
    return
    
    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    #disable delete
    redirect_to posts_path
    return
    
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url }
      format.json { head :no_content }
    end
  end
  
  def like
    post = Post.find(params[:id])
    current_user = resource_owner(params[:access_token]) if current_user.nil?

    if Like.where("post_id=? AND user_id=?",params[:id],current_user.id).exists? == false \
      and post.user.id != current_user.id
        like = Like.new
        like.post_id = post.id
        like.user_id = current_user.id
        like.save!
      
      if request.format.json? 
        render :json=>'success', status: :created
      else
        redirect_to :action=>'show', :id=>post.root_parent
      end
      return
    end
    
    respond_to do |format|
      format.html { redirect_to :action=>'show', :id=>post.root_parent }
      format.json { render :json=>'Like failed', status: :unprocessable_entity }
    end
  end
  
  protected
  
  def check_required_params
    if (params[:lat].blank? or params[:lon].blank?)
      if request.format.json? 
        render :json => 'Missing required parameters (lat and/or lon)', :status => :unprocessable_entity
      else
        raise 'Missing required parameters (lat and/or lon)'
      end
      return
    end
  end
end
