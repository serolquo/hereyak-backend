class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable,
         :timeoutable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :first_name, :last_name, :username, :registered_on,
                  :deleted_at, :active, :avatar
  # attr_accessible :title, :body
  
  validates :username, :uniqueness => true
  validates :username, :format => { :with=>/\A[a-zA-Z0-9]+\z/,
    :message => 'can only contain letters and numbers'
  }
  validates :username, :length => {:maximum=>32, 
        :too_long=>"cannot contain more than %{count} characters",
        :minimum=>3,
        :too_short => "must contain at least %{count} characters"
  }
  
  has_many :client_applications
  has_many :tokens, :class_name => "OauthToken", :order => "authorized_at desc", :include => [:client_application]
  
  has_many :posts
  has_many :likes
  
  has_attached_file :avatar, 
      :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
      :url => "/system/:attachment/:id/:style/:filename",
      :hash_secret => "geosciencepracticeandethics", 
      :styles => { :medium => ["128x128>", :png], :thumb => ["48x48#",:png] }
  
  validates_attachment :avatar, 
    :content_type => { :content_type => ["image/jpg", "image/png", "image/gif"] },
    :size => { :less_than => 1.megabytes }, :on => :update
  
  def soft_delete
    update_attributes(:deleted_at=>Time.current, :active=>0)
  end
  
  def avatar_url(style_name=nil)
    return self.avatar.url(style_name) if self.avatar.present?
    return '/assets/unknown_user.png' if style_name.nil?
    image_urls = Hash.new()
    image_urls[:medium] = '/assets/unknown_user128.png'
    image_urls[:thumb] = '/assets/unknown_user48.png'
    return image_urls[style_name]
  end
  
  def self.find_for_authentication(conditions) 
    super(conditions.merge(:active => 1))
  end
end
