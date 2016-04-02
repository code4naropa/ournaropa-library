$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ournaropa_library/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ournaropa_library"
  s.version     = OurnaropaLibrary::VERSION
  s.authors     = ["Finn Woelm"]
  s.email       = ["finn.woelm@gmail.com"]
  s.homepage    = "http://www.ournaropa.org"
  s.summary     = "Summary of OurnaropaLibrary."
  s.description = "Description of OurnaropaLibrary."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.4"

  s.add_development_dependency "sqlite3"
end
