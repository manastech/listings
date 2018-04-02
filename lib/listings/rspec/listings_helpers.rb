module RSpec::ListingsHelpers
  class FakeRoutes
    # def listing_full_path(*options)
    #   "/"
    # end

    # def listing_full_url(*options)
    #   "/"
    # end

    # def listing_content_url(*options)
    #   "/"
    # end

    # def listing_export_url(*options)
    #   "/"
    # end

    def method_missing(m, *args, &block)
      if m.to_s.end_with?("_url") || m.to_s.end_with?("_path")
        "/"
      else
        super
      end
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

    controller.request = if Rails::VERSION::MAJOR < 5
      ActionController::TestRequest.new(:host => "http://test.com")
    else
      if Rails::VERSION::MINOR >= 1 # ~> 5.1
        ActionController::TestRequest.create(controller.class)
      else
        ActionController::TestRequest.create
      end
    end
    context = controller.view_context

    context.class.send(:define_method, 'listings') do
      FakeRoutes.new
    end

    context.class.send(:define_method, 'main_app') do
      FakeRoutes.new # routes of the main_app
    end

    context
  end

end
