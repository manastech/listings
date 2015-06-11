FactoryGirl.define do
  factory :album do
    name "MyString"

    transient do
      tracks_count 5
    end

    after(:create) do |album, evaluator|
      create_list(:track, evaluator.tracks_count, album: album)
    end
  end

end
