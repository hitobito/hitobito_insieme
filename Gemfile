#  Copyright (c) 2014, Insieme Schweiz. This file is part of
#  hitobito_cevi and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_cevi.

load File.expand_path('../app_root.rb', __FILE__)

source 'https://rubygems.org'

# Declare your gem's dependencies in hitobito_insieme.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Load application Gemfile for all application dependencies.
# rubocop:disable Eval
eval File.read(File.expand_path('Gemfile', ENV['APP_ROOT']))

group :development, :test do
  # Explicitly define the path for dependencies on other wagons.
  # gem 'hitobito_other_wagon', :path => "#{ENV['APP_ROOT']}/vendor/wagons"
end
