class ArrayListing < Listings::Base

  model { (1..50).to_a }

  scope 'Todos', :all, default: true
  scope 'Impares', :impares, lambda { |items| items.select{|i| i % 2 == 1} }
  deferred_scopes do
    (0..3).each do |i|
      scope "scope#{i}", "sym#{i}".to_sym, lambda { |items| items.select{|item| item % 4 == i} }
    end
  end

  paginates_per 10

  column 'Num' do |n|
    n
  end

  column 'Num+1' do |n|
    n+1
  end

end
