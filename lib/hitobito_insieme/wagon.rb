# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module HitobitoInsieme
  class Wagon < Rails::Engine
    include Wagons::Wagon

    # Set the required application version.
    app_requirement '>= 0'

    # Add a load path for this specific wagon
    config.autoload_paths += %W( #{config.root}/app/abilities
                                 #{config.root}/app/domain
                                 #{config.root}/app/jobs
                             )

    config.to_prepare do
      # rubocop:disable SingleSpaceBeforeFirstArg
      # extend application classes here
      Group.send        :include, Insieme::Group
      Person.send       :include, Insieme::Person

      PersonSerializer.send :include, Insieme::PersonSerializer
      GroupSerializer.send  :include, Insieme::GroupSerializer

      GroupAbility.send :include, Insieme::GroupAbility

      PeopleController.permitted_attrs +=
        [:salutation, :canton, :language, :correspondence_language, :number, :insieme_full_name]

      # Permit person address fields
      %w( correspondence_general
          billing_general
          correspondence_course
          billing_course ).each do |prefix|
        %w( full_name company_name company address zip_code town country).each do |field|
          PeopleController.permitted_attrs << :"#{prefix}_#{field}"
        end
      end

      Sheet::Group.send :include, Insieme::Sheet::Group

      Export::Csv::People::PeopleAddress.send :include, Insieme::Export::Csv::People::PeopleAddress
      # rubocop:enable SingleSpaceBeforeFirstArg
    end

    initializer 'insieme.add_settings' do |_app|
      Settings.add_source!(File.join(paths['config'].existent, 'settings.yml'))
      Settings.reload!
    end

    private

    def seed_fixtures
      fixtures = root.join('db', 'seeds')
      ENV['NO_ENV'] ? [fixtures] : [fixtures, File.join(fixtures, Rails.env)]
    end

  end
end
