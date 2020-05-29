# frozen_string_literal: true

#  Copyright (c) 2014 insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module AboAddresses
  class Query

    INCLUDED_LAYERS = [Group::Dachverein, Group::Regionalverein]

    INCLUDED_ROLES = [Group::DachvereinAbonnemente::Einzelabo,
                      Group::DachvereinAbonnemente::Geschenkabo,
                      Group::DachvereinAbonnemente::Gratisabo,
                      Group::Aktivmitglieder::Aktivmitglied,
                      Group::Kollektivmitglieder::KollektivmitgliedMitAbo,
                      Group::Passivmitglieder::PassivmitgliedMitAbo]

    # must match with attrs exported in csv
    REQUIRED_ATTRS = [:id, :first_name, :last_name, :company_name, :address,
                      :zip_code, :town, :country, :number]

    attr_reader :swiss, :language

    def initialize(swiss, language)
      @swiss = swiss
      @language = language
    end

    def people
      Person.joins(roles: :group).
             joins('INNER JOIN groups layers ON groups.layer_group_id = layers.id').
             where(roles: { type: INCLUDED_ROLES.collect(&:sti_name) }).
             where(layers: { type: INCLUDED_LAYERS.collect(&:sti_name) }).
             where(language_condition).
             where(country_condition).
             select(*REQUIRED_ATTRS).
             order(:number).
             distinct
    end

    private

    def language_condition
      if language == 'fr'
        { correspondence_language: 'fr' }
      else
        ['correspondence_language IS NULL OR correspondence_language IN (?)', ['de', '']]
      end
    end

    def country_condition
      normalized_country = "TRIM(LOWER(COALESCE(people.country, '')))"
      in_or_not = swiss ? 'IN' : 'NOT IN'
      swiss_countries = ['', 'ch']

      ["#{normalized_country} #{in_or_not} (?)", swiss_countries]
    end

  end
end
