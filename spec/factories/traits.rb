FactoryGirl.define do
  sequence :title do |n|
    "title #{rand(1000)} #{n}"
  end

  sequence :name do |n|
    "name #{rand(1000)} #{n}"
  end
end
