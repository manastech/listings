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

    def initialize
      @theme = 'twitter-bootstrap-2'
    end
  end
end
