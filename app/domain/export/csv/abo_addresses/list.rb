# encoding: utf-8

#  Copyright (c) 2014 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Export::Csv::AboAddresses
  class List < Export::Csv::Base

    self.model_class = Person

    def attribute_labels
      { number: 'Kd.Nr.',
        name: 'Vorname und Name',
        addition_1: 'Zusatz 1',
        addition_2: 'Zusatz 2',
        address: 'Adresse',
        place: 'PLZ und Ort',
        country: 'Land' }
    end

    class Row < Export::Csv::Row

      def name
        "#{entry.first_name} #{entry.last_name}".strip
      end

      def addition_1
        entry.company_name
      end

      def addition_2
        nil
      end

      def place
        "#{entry.zip_code} #{entry.town}".strip
      end

      def country
        entry.country unless entry.ignored_country?
      end
    end

    self.row_class = Row

  end
end
