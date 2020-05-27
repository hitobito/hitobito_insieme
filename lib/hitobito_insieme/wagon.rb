# encoding: utf-8
# frozen_string_literal: true

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
    config.autoload_paths += %W[
      #{config.root}/app/abilities
      #{config.root}/app/decorators
      #{config.root}/app/domain
      #{config.root}/app/jobs
    ]

    config.to_prepare do # rubocop:disable Metrics/BlockLength
      # extend application classes here

      # models
      unless Cantons::SHORT_NAMES.include?(:another)
        Cantons::SHORT_NAMES << :another
      end

      Group.include Insieme::Group
      Person.include Insieme::Person
      Person.include Insieme::PersonNumber
      Event.include Insieme::Event
      Event::Course.include Insieme::Event::Course
      Event::Participation.include Insieme::Event::Participation
      Event::Role::Permissions << :reporting

      # serializers
      PersonSerializer.include Insieme::PersonSerializer
      GroupSerializer.include Insieme::GroupSerializer

      # abilities
      GroupAbility.include Insieme::GroupAbility
      EventAbility.include Insieme::EventAbility
      Event::ParticipationAbility.include Insieme::Event::ParticipationAbility
      PersonAbility.include Insieme::PersonAbility
      MailingListAbility.include Insieme::MailingListAbility
      VariousAbility.include Insieme::VariousAbility
      PersonReadables.prepend Insieme::PersonReadables
      Ability.store.register Event::CourseRecordAbility

      # controllers
      PeopleController.prepend Insieme::PeopleController
      PeopleController.prepend Insieme::RenderPeopleExports
      EventsController.prepend Insieme::EventsController
      Event::ParticipationsController.prepend Insieme::Event::ParticipationsController
      Event::ParticipationsController.prepend Insieme::RenderPeopleExports
      Event::RegisterController.prepend Insieme::Event::RegisterController
      Person::QueryController.search_columns << :number

      # helpers
      Sheet::Base.prepend Insieme::Sheet::Base
      Sheet::Group.include Insieme::Sheet::Group
      Sheet::Event.include Insieme::Sheet::Event
      Dropdown::LabelItems.prepend Insieme::Dropdown::LabelItems
      StandardFormBuilder.include Insieme::StandardFormBuilder

      # decorators
      PersonDecorator.prepend Insieme::PersonDecorator
      EventDecorator.prepend Insieme::EventDecorator

      # domain
      Export::Tabular::People::PeopleAddress.prepend Insieme::Export::Tabular::People::PeopleAddress
      Export::Tabular::People::PeopleFull.prepend Insieme::Export::Tabular::People::PeopleFull
      Export::Tabular::People::PersonRow.include Insieme::Export::Tabular::People::PersonRow
      Export::Tabular::People::ParticipationsFull.prepend(
        Insieme::Export::Tabular::People::ParticipationsFull
      )
      Export::Tabular::People::ParticipationRow.include(
        Insieme::Export::Tabular::People::ParticipationRow
      )
      Export::Tabular::Events::List.prepend Insieme::Export::Tabular::Events::List
      Export::Tabular::Events::Row.include Insieme::Export::Tabular::Events::Row
      Export::Pdf::Labels.prepend Insieme::Export::Pdf::Labels
      Import::PersonDoubletteFinder.prepend Insieme::Import::PersonDoubletteFinder

      Export::Xlsx::Style.register(Export::Xlsx::CostAccounting::Style,
                                   Export::Tabular::CostAccounting::List)

      Export::Xlsx::Style.register(Export::Xlsx::Events::Style,
                                   Export::Tabular::Events::DetailList,
                                   Export::Tabular::Events::ShortList)

      Export::Xlsx::Style.register(Export::Xlsx::Events::AggregateCourse::Style,
                                   Export::Tabular::Events::AggregateCourse::DetailList,
                                   Export::Tabular::Events::AggregateCourse::ShortList)

      # jobs
      Export::SubscriptionsJob.prepend Insieme::Export::SubscriptionsJob
      Export::EventsExportJob.prepend Insieme::Export::EventsExportJob


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
