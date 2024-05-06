# frozen_string_literal: true

#  Copyright (c) 2014-2024, Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Export::Tabular::AboAddresses
  class List < Export::Tabular::Base

    self.model_class = ::Person

    def attribute_labels
      { number: 'Kd.Nr.',
        name: 'Vorname und Name',
        company: 'Firma',
        address_1: 'Adresse 1',
        address_2: 'Adresse 2',
        address_3: 'Adresse 3',
        place: 'PLZ und Ort',
        country: 'Land' }
    end

    class Row < Export::Tabular::Row

      def name
        "#{entry.first_name} #{entry.last_name}".strip
      end

      def company
        entry.company_name
      end

      def address_1
        address_line(0)
      end

      def address_2
        address_line(1)
      end

      def address_3
        address_line(2)
      end

      def place
        "#{entry.zip_code} #{entry.town}".strip
      end

      def country
        entry.country unless entry.ignored_country?
      end

      private

      def address_line(line_index)
        lines = if FeatureGate.enabled?('structured_addresses')
                  [
                    entry.address_care_of,
                    entry.address,
                    entry.postbox
                  ].compact
                else
                  entry.address.to_s.split($INPUT_RECORD_SEPARATOR)
                end

        line = lines[line_index]
        line ? line.strip : nil
      end
    end

    self.row_class = Row

  end
end
