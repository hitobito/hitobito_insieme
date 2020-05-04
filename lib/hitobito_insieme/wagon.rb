# encoding: utf-8

#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module HitobitoInsieme
  class Wagon < Rails::Engine
    include Wagons::Wagon

    # Set the required application version.
    app_requirement '>= 0'

    # Add a load path for this specific wagon
    config.autoload_paths += %W(
      #{config.root}/app/abilities
      #{config.root}/app/decorators
      #{config.root}/app/domain
      #{config.root}/app/jobs
    )

    config.to_prepare do
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
      PersonReadables.send    :prepend, Insieme::PersonReadables
      Ability.store.register Event::CourseRecordAbility

      # controllers
      PeopleController.send :prepend, Insieme::PeopleController
      PeopleController.send :prepend, Insieme::RenderPeopleExports
      EventsController.send :prepend, Insieme::EventsController
      Event::ParticipationsController.send :prepend, Insieme::Event::ParticipationsController
      Event::ParticipationsController.send :prepend, Insieme::RenderPeopleExports
      Event::RegisterController.send       :prepend, Insieme::Event::RegisterController
      Person::QueryController.search_columns << :number

      # helpers
      Sheet::Base.send  :prepend, Insieme::Sheet::Base
      Sheet::Group.send :include, Insieme::Sheet::Group
      Sheet::Event.send :include, Insieme::Sheet::Event
      Dropdown::LabelItems.send :prepend, Insieme::Dropdown::LabelItems

      # decorators
      PersonDecorator.send :prepend, Insieme::PersonDecorator
      EventDecorator.send  :prepend, Insieme::EventDecorator

      # domain
      Export::Tabular::People::PeopleAddress.send(
        :prepend, Insieme::Export::Tabular::People::PeopleAddress
      )
      Export::Tabular::People::PeopleFull.send(
        :prepend, Insieme::Export::Tabular::People::PeopleFull
      )
      Export::Tabular::People::PersonRow.send(
        :include, Insieme::Export::Tabular::People::PersonRow
      )
      Export::Tabular::People::ParticipationsFull.send(
        :prepend, Insieme::Export::Tabular::People::ParticipationsFull
      )
      Export::Tabular::People::ParticipationRow.send(
        :include, Insieme::Export::Tabular::People::ParticipationRow
      )
      Export::Tabular::Events::List.send :prepend, Insieme::Export::Tabular::Events::List
      Export::Tabular::Events::Row.send  :include, Insieme::Export::Tabular::Events::Row
      Export::Pdf::Labels.send           :prepend, Insieme::Export::Pdf::Labels
      Import::PersonDoubletteFinder.send :prepend, Insieme::Import::PersonDoubletteFinder

      Export::Xlsx::Style.register(Export::Xlsx::CostAccounting::Style,
                                   Export::Tabular::CostAccounting::List)

      Export::Xlsx::Style.register(Export::Xlsx::Events::Style,
                                   Export::Tabular::Events::DetailList,
                                   Export::Tabular::Events::ShortList)

      Export::Xlsx::Style.register(Export::Xlsx::Events::AggregateCourse::Style,
                                   Export::Tabular::Events::AggregateCourse::DetailList,
                                   Export::Tabular::Events::AggregateCourse::ShortList)

      # jobs
      Export::SubscriptionsJob.send :prepend, Insieme::Export::SubscriptionsJob
      Export::EventsExportJob.send  :prepend, Insieme::Export::EventsExportJob


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
