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
                                 #{config.root}/app/decorators
                                 #{config.root}/app/domain
                                 #{config.root}/app/jobs
                             )

    config.to_prepare do
      # rubocop:disable SingleSpaceBeforeFirstArg
      # extend application classes here

      # models
      Cantons::SHORT_NAMES << :another

      Group.send         :include, Insieme::Group
      Person.send        :include, Insieme::Person
      Person.send        :include, Insieme::PersonNumber
      Event.send         :include, Insieme::Event
      Event::Course.send :include, Insieme::Event::Course
      Event::Participation.send :include, Insieme::Event::Participation
      Event::Role::Permissions << :reporting

      # serializers
      PersonSerializer.send :include, Insieme::PersonSerializer
      GroupSerializer.send  :include, Insieme::GroupSerializer

      # abilities
      GroupAbility.send       :include, Insieme::GroupAbility
      EventAbility.send       :include, Insieme::EventAbility
      Event::ParticipationAbility.send :include, Insieme::Event::ParticipationAbility
      PersonAbility.send      :include, Insieme::PersonAbility
      MailingListAbility.send :include, Insieme::MailingListAbility
      VariousAbility.send     :include, Insieme::VariousAbility
      PersonReadables.send :include, Insieme::PersonReadables
      Ability.store.register Event::CourseRecordAbility

      # controllers
      PeopleController.send :include, Insieme::PeopleController
      PeopleController.send :include, Insieme::RenderPeopleExports
      EventsController.send :include, Insieme::EventsController
      SubscriptionsController.send         :include, Insieme::SubscriptionsController
      Event::ParticipationsController.send :include, Insieme::Event::ParticipationsController
      Event::ParticipationsController.send :include, Insieme::RenderPeopleExports
      Event::RegisterController.send       :include, Insieme::Event::RegisterController
      Person::QueryController.search_columns << :number

      # helpers
      Sheet::Base.send  :include, Insieme::Sheet::Base
      Sheet::Group.send :include, Insieme::Sheet::Group
      Sheet::Event.send :include, Insieme::Sheet::Event
      Dropdown::PeopleExport.send :include, Insieme::Dropdown::PeopleExport

      # decorators
      PersonDecorator.send :include, Insieme::PersonDecorator
      EventDecorator.send :include, Insieme::EventDecorator

      # domain
      Export::Csv::People::PeopleAddress.send :include, Insieme::Export::Csv::People::PeopleAddress
      Export::Csv::People::PeopleFull.send(:include, Insieme::Export::Csv::People::PeopleFull)
      Export::Csv::People::PersonRow.send(:include, Insieme::Export::Csv::People::PersonRow)
      Export::Pdf::Labels.send :include, Insieme::Export::Pdf::Labels
      Import::PersonDoubletteFinder.send :include, Insieme::Import::PersonDoubletteFinder
      Export::Csv::People::ParticipationsFull.send(
        :include,
        Insieme::Export::Csv::People::ParticipationsFull)
      Export::Csv::People::ParticipationRow.send(
        :include,
        Insieme::Export::Csv::People::ParticipationRow)
      Export::Xlsx::Events::List.send :include, Insieme::Export::Xlsx::Events::List
      Export::Xlsx::Events::Row.send :include, Insieme::Export::Xlsx::Events::Row
      # rubocop:enable SingleSpaceBeforeFirstArg

      admin = NavigationHelper::MAIN.find { |opts| opts[:label] == :admin }
      admin[:active_for] << 'reporting_parameters' << 'global_value'
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
