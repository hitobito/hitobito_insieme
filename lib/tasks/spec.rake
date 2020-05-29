# frozen_string_literal: true
#  Copyright (c) 2012-2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# encoding: utf-8

if Rake::Task.task_defined?('spec:features')
  # we DO have feature specs in this wagon.
  Rake::Task['spec:features'].actions.clear
  namespace :spec do
    RSpec::Core::RakeTask.new(:features) do |t|
      t.pattern = './spec/features/**/*_spec.rb'
    end

    task all: ['spec:features', 'spec']
  end

else
  # we do NOT have feature specs in this wagon.
  namespace :spec do
    task all: 'spec'
  end
end
