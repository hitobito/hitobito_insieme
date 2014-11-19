# encoding: utf-8

#  Copyright (c) 2014 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Export::Csv::Statistics
  class Vereinsmitglieder < Export::Csv::Base

    class Row < Export::Csv::Row
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
        item = { vid: group.vid, name: group.name }
        counted_roles do |role, index|
          item[role.sti_name] = vereinsmitglieder.count(group, index)
        end
        [:full_name, :address, :zip_code, :town].each do |attr|
          item[attr] = group.send(attr)
        end
        item[:canton] = group.canton_value
        item
      end
    end

    def build_attribute_labels
      labels = { vid: human_attribute(:vid), name: human_attribute(:name) }
      counted_roles do |role, index|
        labels[role.sti_name] = role.label_plural
      end
      [:full_name, :address, :zip_code, :town, :canton].each do |attr|
        labels[attr] = human_attribute(attr)
      end
      labels
    end

    def counted_roles(&block)
      ::Statistics::Vereinsmitglieder::COUNTED_ROLES.each_with_index(&block)
    end

  end
end
