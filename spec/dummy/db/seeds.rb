require 'factory_girl'
# Dir[Rails.root.join("spec/factories/*.rb")].each {|f| require f}

AUTHORS = []

(1..20).each do |sn|
  AUTHORS << Author.create!(name: "john-#{(sn % 20) + 1}", category: "category-#{(sn % 3) + 1}")
end

(1..100).each do |sn|
  Post.create! title: "post n-#{sn}", author: AUTHORS[sn % (sn / 10 + 1)], category: "category-#{(sn % 3) + 1}"
end

(1..10).each do |sn|
  FactoryGirl.create :album
end

LABELS = %w(Green Red Blue)

(1..10).each do |sn|
  FactoryGirl.create :track, album: nil, label: LABELS[sn % LABELS.size]
end
