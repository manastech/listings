
(1..30).each do |sn|
  Post.create! title: "post n-#{sn}"
end

