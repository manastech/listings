require "listings/rspec/listings_helpers"

RSpec.configure do |config|
  config.include RSpec::ListingsHelpers, type: :listing
end
