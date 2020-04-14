class Author < ActiveRecord::Base
  attr_accessible :name, :category if Rails::VERSION::MAJOR == 3

  has_many :posts
end
