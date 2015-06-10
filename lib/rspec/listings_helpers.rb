module RSpec::ListingsHelpers
  class FakeViewContext
    include ::Listings::ActionViewExtensions

    def listings
      nil
    end
  end

  def query_listing(name)
    context = FakeViewContext.new
    context.prepare_listing({:listing => name}, context)
  end

end
