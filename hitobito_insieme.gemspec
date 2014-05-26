$:.push File.expand_path("../lib", __FILE__)

# Maintain your wagon's version:
require "hitobito_insieme/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "hitobito_insieme"
  s.version     = HitobitoInsieme::VERSION
  s.authors     = ["Pascal Zumkehr"]
  s.email       = ["zumkehr@puzzle.ch"]
  s.summary     = "Insieme organisation specific features"
  s.description = "Insieme organisation specific features"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile"]
  s.test_files = Dir["test/**/*"]

end
