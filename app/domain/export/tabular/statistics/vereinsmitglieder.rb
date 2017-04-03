# encoding: utf-8

#  Copyright (c) 2014 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Export::Tabular::Statistics
  class Vereinsmitglieder < Export::Tabular::Base

    class Row < Export::Tabular::Row
      def value_for(attr)
        entry.fetch(attr)
      end
    end

    self.row_class = Row
    self.model_class = Group::Regionalverein

    attr_reader :vereinsmitglieder

    def initialize(vereinsmitglieder)
      @vereinsmitglieder = vereinsmitglieder
      super(build_list)
    end

    private

    def build_list
      vereinsmitglieder.vereine.collect do |group|
        {}.tap do |item|
          add_attr_values(item, group, :vid, :name)
          add_role_counts(item, group)
          add_attr_values(item, group, :full_name, :address, :zip_code, :town)
          item[:canton] = group.canton_label
        end
      end
    end

    def build_attribute_labels
      {}.tap do |labels|
        add_attr_labels(labels, :vid, :name)
        add_role_labels(labels)
        add_attr_labels(labels, :full_name, :address, :zip_code, :town, :canton)
      end
    end

    def add_attr_values(item, group, *attrs)
      add_hash_values(item, attrs) { |attr, _| group.send(attr) }
    end

    def add_attr_labels(labels, *attrs)
      add_hash_values(labels, attrs) { |attr, _| human_attribute(attr) }
    end

    def add_role_counts(item, group)
      add_hash_values(item, counted_roles) { |_, index| vereinsmitglieder.count(group, index) }
    end

    def add_role_labels(labels)
      add_hash_values(labels, counted_roles) { |role, _| role.label_plural }
    end

    def add_hash_values(hash, keys)
      keys.each_with_index do |key, index|
        hash[key] = yield key, index
      end
    end

    def counted_roles
      ::Statistics::Vereinsmitglieder::COUNTED_ROLES
    end

  end
end
