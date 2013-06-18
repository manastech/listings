
(1..100).each do |sn|
  Post.create! title: "post n-#{sn}", author: "john-#{(sn % 4) + 1}"
end

