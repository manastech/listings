class Post < ActiveRecord::Base
  attr_accessible :title, :author, :category if Rails::VERSION::MAJOR == 3

  belongs_to :author

  scope :even, -> { where('id % 2 = 0') }
  scope :odd, -> { where('id % 2 = 1') }
  scope :greater_than, lambda { |gt_id| where('id > ?', gt_id) }
end
