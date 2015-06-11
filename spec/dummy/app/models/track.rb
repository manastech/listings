class Track < ActiveRecord::Base
  belongs_to :album
  attr_accessible :order, :title if Rails::VERSION::MAJOR == 3
end
