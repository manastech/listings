$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "listings/version"

travis = ENV["TRAVIS"] || "false"

rails_version = ENV["RAILS_VERSION"] || "default"
rails = case rails_version
when "default"
  nil
else
  "~> #{rails_version}"
end

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "listings"
  s.version     = Listings::VERSION
  s.authors     = ["Brian J. Cardiff"]
  s.email       = ["bcardiff@gmail.com"]
  s.homepage    = "https://github.com/manastech/listings"
  s.summary     = "Simple creation of listings in rails applications."
  s.description = "Simple creation of listings in rails applications."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["{test,spec}/**/*"] - Dir["{test,spec}/dummy/tmp/**/*"]

  s.add_dependency "rails", rails
  s.add_dependency 'haml-rails'
  s.add_dependency 'sass-rails'
  s.add_dependency 'kaminari'
  s.add_dependency 'bootstrap-kaminari-views'
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_girl_rails'

  if travis == "false"
    s.add_development_dependency 'pry'
    s.add_development_dependency 'pry-debugger'
  end
end
