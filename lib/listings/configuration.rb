module Listings
  class << self
    attr_accessor :configuration

    def configuration
      @configuration ||= Configuration.new
    end
  end

  def self.configure
    yield(self.configuration)
  end

  class Configuration
    attr_accessor :theme
    attr_accessor :push_url # use html5 pushState to allow back navigation of listings. default false.

    def initialize
      @theme = 'twitter-bootstrap-2'
      @push_url = false
    end
  end
end
