class Post < ActiveRecord::Base
  attr_accessible :title

  scope :even, where('id % 2 = 0')
  scope :odd, where('id % 2 = 1')
end
