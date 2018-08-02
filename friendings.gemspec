$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "friendings/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "friendings"
  s.version     = Friending::VERSION
  s.authors     = ["Sukhbir Singh"]
  s.email       = ["sukhbir947@gmail.com"]
  s.homepage    = "http://www.amahi.org/apps/friending"
  s.license     = "AGPLv3"
  s.summary     = %{Friending feature for Amahi 11.}
  s.description = %{This is an Amahi 11 platform plugin using which an Amahi user can add another user as a friend and can give him some access to shares on his HDA.}

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 5.2.0"
  s.add_dependency "jquery-rails"
  s.add_dependency "rest-client"

  s.add_development_dependency "sqlite3"
end
