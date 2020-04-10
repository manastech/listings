class Track < ActiveRecord::Base
  belongs_to :album
  attr_accessible :order, :title, :label if Rails::VERSION::MAJOR == 3

  scope :even, -> { where("#{table_name}.id % 2 = 0") }

end
