module RSpec::ListingsHelpers
  class FakeRoutes
    def listing_full_path(*options)
      "/"
    end

    def listing_full_url(*options)
      "/"
    end
  end

  def query_listing(name)
    context = fake_context
    context.prepare_listing({:listing => name}, context)
  end

  def render_listing(name)
    fake_context.render_listing(name)
  end

  def fake_context
    controller = ActionController::Base.new
    controller.request = ActionController::TestRequest.new(:host => "http://test.com")
    context = controller.view_context

    context.class.send(:define_method, 'listings') do
      FakeRoutes.new
    end

    context
  end

end
