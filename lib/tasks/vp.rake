# frozen_string_literal: true

#  Copyright (c) 2022, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

namespace :vp do
  desc 'Copy a Vertragsperiode to start a new one'
  task :new, [:year] => [:environment] do |_, args|
    args.with_defaults(year: Date.current.year)
    year = args[:year].to_i

    known_years = Vertragsperioden::Dispatcher::KNOWN_VP_BASE_YEARS
    last_year = known_years.last

    raise "#{year} is already known" if known_years.include? year

    puts "#{last_year} -> #{year}"

    domain_path = Pathname.new('app/domain/').expand_path
    spec_path = Pathname.new('spec/').expand_path
    view_path = Pathname.new('app/views/').expand_path

    # copy customized views
    new_year_views = view_path.join("vp#{year}")
    cp_r view_path.join("vp#{last_year}"), new_year_views

    # copy domain
    new_year_domain = domain_path.join("vp#{year}")
    cp_r domain_path.join("vp#{last_year}"), new_year_domain

    # adapt domain
    sh "find #{new_year_domain} -type f | " \
       "xargs -l1 sed -i 's/Vp#{last_year}/Vp#{year}/'"

    # copy specs
    new_year_specs = spec_path.join("vp#{year}")
    cp_r spec_path.join("vp#{last_year}"), new_year_specs

    # adapt specs
    sh "find #{new_year_specs} -type f | " \
       "xargs -l1 sed -i 's/#{last_year}/#{year}/'"

    # adapt dispatcher
    new_supported_years = known_years + [year.to_i]
    sh <<~BASH
      sed -i \
        's/KNOWN_VP_BASE_YEARS = \\[.*\\]/KNOWN_VP_BASE_YEARS = [#{new_supported_years.join(', ')}]/' \
        app/domain/vertragsperioden/dispatcher.rb
    BASH

    puts 'TODOs:'
    puts "- Adapt app/domain/vertragsperioden/dispatcher.rb to include #{year} in #determine."
    puts "- Adapt spec/domain/vertragsperioden/dispatcher_spec.rb to cover #{year}."
    puts '- Run specs an fix failing ones'
    puts "- check views in app/views/vp#{year} for mistakes"
    puts '- check locales for wrong or missing vertragsperioden-descriptions'
    puts '- inform client about the need to change translations'
  end
end
