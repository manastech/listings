class Post < ActiveRecord::Base
  attr_accessible :title, :author

  scope :even, where('id % 2 = 0')
  scope :odd, where('id % 2 = 1')
end
