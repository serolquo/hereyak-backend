class Post < ActiveRecord::Base
  attr_accessible :content, :latitude, :longitude, :post_date, :reply_to_post, :user_id, :city,:province,:country,:postal_code
  validates :content, :length=>{
        :maximum=>256, 
        :too_long=>"cannot contain more than %{count} characters",
        :minimum=>3,
        :too_short => "must contain at least %{count} characters"
      }
  validate :lat_and_lon_cannot_be_zero
  #validates :city, :presence => true
  #validates :province, :presence => true
  #validates :country, :presence => true
  
  reverse_geocoded_by :latitude, :longitude do |obj,results|
    if geo = results.first
      obj.city    = geo.city
      obj.province = geo.state
      obj.postal_code = geo.postal_code
      obj.country = geo.country_code
    end
  end
  after_validation :reverse_geocode
  
  def lat_and_lon_cannot_be_zero
    puts latitude.to_s.eql?('0.0')
    if latitude.to_s.eql?('0.0') and longitude.to_s.eql?('0.0')
      errors.add(:post,"cannot be submitted because your location is unknown")
    end
  end
  
  belongs_to :user
  has_many :likes
  has_many :tags
  has_many :tag_names, :through => :tags

  belongs_to :parent_post, class_name: "Post", foreign_key: "reply_to_post"
  has_many :replies, class_name: "Post", foreign_key: "reply_to_post"
  
  #not used before of 1 level reply restriction
  #def all_replies
  #  replies = Array.new
  #  children = Array.new
  #  children << self.replies
  #  children.flatten!
  #  until (children.empty?) do
  #    children.flatten!
  #    child = children.shift
  #    replies << child
  #    children << child.replies if child.replies.size > 0
  #  end
  #  replies.flatten
  #end
  
  alias :all_replies :replies
  
  def number_of_replies
    all_replies.size
  end
  
  def number_of_likes
    likes.size
  end
  
  
  def root_parent
    parent = self.parent_post
    post = self
    until (parent.nil?) do
      post = parent
      parent = parent.parent_post
    end
    return post
  end
end
