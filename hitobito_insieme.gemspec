# frozen_string_literal: true
#  Copyright (c) 2014, Insieme Schweiz. This file is part of
#  hitobito_cevi and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_cevi.

$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your wagon's version:
require 'hitobito_insieme/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'hitobito_insieme'
  s.version     = HitobitoInsieme::VERSION
  s.authors     = ['Pascal Zumkehr']
  s.email       = ['zumkehr@puzzle.ch']
  s.summary     = 'Insieme organisation specific features'
  s.description = 'Insieme organisation specific features'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['Rakefile']
  s.test_files = Dir['test/**/*']

end
