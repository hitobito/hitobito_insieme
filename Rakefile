#!/usr/bin/env rake
# frozen_string_literal: true

#  Copyright (c) 2014, Insieme Schweiz. This file is part of
#  hitobito_cevi and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_cevi.

begin
  require "bundler/setup"
rescue LoadError
  puts "You must `gem install bundler` and `bundle install` to run rake tasks"
end

ENGINE_PATH = File.expand_path("..", __FILE__)
load File.expand_path("../app_root.rb", __FILE__)

load "wagons/wagon_tasks.rake"

load "rspec/rails/tasks/rspec.rake"

require "ci/reporter/rake/rspec" unless Rails.env.production?

HitobitoInsieme::Wagon.load_tasks
