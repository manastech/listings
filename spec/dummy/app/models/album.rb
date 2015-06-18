class Album < ActiveRecord::Base
  attr_accessible :name if Rails::VERSION::MAJOR == 3
  has_many :tracks
end
