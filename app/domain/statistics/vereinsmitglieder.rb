# frozen_string_literal: true

#  Copyright (c) 2014 insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Statistics
  class Vereinsmitglieder
    COUNTED_ROLES = [Group::Aktivmitglieder::Aktivmitglied,
      Group::Aktivmitglieder::AktivmitgliedOhneAbo,
      Group::Aktivmitglieder::Zweitmitgliedschaft,
      Group::Kollektivmitglieder::Kollektivmitglied,
      Group::Kollektivmitglieder::KollektivmitgliedMitAbo,
      Group::Passivmitglieder::Passivmitglied,
      Group::Passivmitglieder::PassivmitgliedMitAbo].freeze

    def vereine
      @vereine ||= Group::Regionalverein.without_deleted.includes(:contact).order(:name)
    end

    def count(layer, index)
      counts = type_counts[layer.id]
      counts ? counts[index] : 0
    end

    def role_types
      COUNTED_ROLES.each_with_index do |role, index|
        yield role, index
      end
    end

    private

    def type_counts
      @type_counts ||= type_counts_per_layer
    end

    def type_counts_per_layer
      result = Role.connection.execute(type_counts_per_layer_query)
      result.each_with_object({}) do |row, hash|
        hash[row[0]] ||= Hash.new(0)
        hash[row[0]][row[1]] = row[2]
      end
    end

    def type_counts_per_layer_query
      <<-SQL
        SELECT layer_group_id, type_index, COUNT(person_id) AS count
        FROM (#{person_roles_per_layer_query}) AS t
        GROUP BY layer_group_id, type_index
      SQL
    end

    def person_roles_per_layer_query
      <<-SQL
        SELECT `groups`.layer_group_id AS layer_group_id,
               MIN(#{type_index_switch}) AS type_index,
               roles.person_id AS person_id
        FROM roles
        INNER JOIN `groups` `groups` ON `groups`.id = roles.group_id
        INNER JOIN `groups` layers ON layers.id = `groups`.layer_group_id
        WHERE layers.type = '#{Group::Regionalverein.sti_name}' AND
              roles.deleted_at IS NULL AND
              roles.type IN (#{role_types_param})
        GROUP BY `groups`.layer_group_id,
                 roles.person_id
      SQL
    end

    def role_types_param
      COUNTED_ROLES.collect { |r| "'#{r.sti_name}'" }.join(", ")
    end

    def type_index_switch
      statement = "CASE roles.type "
      COUNTED_ROLES.each_with_index do |t, i|
        statement += "WHEN '#{t.sti_name}' THEN #{i} "
      end
      statement += "END"
    end

    def people_per_verein
      roles.each_with_object do |r, hash|
        hash[r.first] ||= {}
        hash[r.first][r.second] ||= []
        hash[r.first][r.second] << r.last
      end
    end
  end
end
