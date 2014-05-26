def init_wagon
  init_app_helper
  config_rspec
end

def init_app_helper
  load File.expand_path('../../app_root.rb', __FILE__)
  ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

  require File.join(ENV['APP_ROOT'], 'spec', 'spec_helper.rb')

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[HitobitoInsieme::Wagon.root.join('spec/support/**/*.rb')].sort.each { |f| require f }
end

def config_rspec
  RSpec.configure do |config|
    config.fixture_path = File.expand_path('../fixtures', __FILE__)
  end
end


init_wagon
