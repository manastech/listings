FactoryGirl.define do
  factory :track do
    title
    order
    album nil
  end

  factory :object_track do
    title
    order
    album nil
  end

end
