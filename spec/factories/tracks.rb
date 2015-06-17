FactoryGirl.define do
  factory :track do
    title
    order 1
    album nil
  end

  factory :object_track do
    title
    order 1
    album nil
  end

end
