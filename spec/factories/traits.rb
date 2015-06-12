FactoryGirl.define do
  sequence :title do |n|
    "title #{n}"
  end

  sequence :name do |n|
    "name #{n}"
  end
end
