FactoryGirl.define do
  factory :album do
    name

    transient do
      tracks_count 5
    end

    after(:create) do |album, evaluator|
      create_list(:track, evaluator.tracks_count, album: album)
    end
  end

  factory :object_album do
    name

    transient do
      tracks_count 5
    end

    after(:build) do |album, evaluator|
      album.tracks = build_list(:object_track, evaluator.tracks_count, album: album)
    end
  end
end
