class TagName < ActiveRecord::Base
  attr_accessible :name
  
  has_many :tags
  has_many :posts, :through => :tags

  def self.find_or_create_many_tag_names(names)
    created_names = Array.new
    names.each {|name|
      created_names << find_or_create_by_name(name)
    }
    created_names
  end  
  
end
