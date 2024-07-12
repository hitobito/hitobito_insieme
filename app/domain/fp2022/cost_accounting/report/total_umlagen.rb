# frozen_string_literal: true

#  Copyright (c) 2012-2014, 2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2022::CostAccounting
  module Report
    # Gemeinkosten
    class TotalUmlagen < Subtotal
      self.total_includes_gemeinkostentraeger = false

      self.summed_reports = %w[
        umlage_mittelbeschaffung

        total_personalaufwand
        raumaufwand
        uebriger_sachaufwand
        abschreibungen
      ]

      self.summed_fields = %w[
        mittelbeschaffung
        verwaltung
        raeumlichkeiten
      ]

      class_attribute :topic_fields
      self.topic_fields = %w[
        beratung
        medien_und_publikationen
        treffpunkte
        blockkurse
        tageskurse
        jahreskurse
        lufeb
      ]

      # this deviates from a "normal" subtotal as specific fields are calculated
      # with specific quotas derived from other specific field. The specifics are
      # mostly contained in the gemeinkosten_quota-method.
      topic_fields.each do |field|
        define_method(field) do
          gemeinkostentraeger * gemeinkosten_quota(field).to_d
        end
      end

      define_summed_field_methods

      def aufwand_ertrag_ko_re
        nil
      end

      private

      def gemeinkosten_quota(field)
        has_employees = table.value_of("lohnaufwand", "total").positive?

        quota_base = (has_employees ? :personalaufwand : :direktkosten)

        one_topic = send(:"#{quota_base}_for_topic", field)
        all_topics = send(:"total_#{quota_base}_for_all_topics")

        return 0 if one_topic.zero? || all_topics.zero?

        one_topic / all_topics
      end

      def personalaufwand_for_topic(field)
        table.value_of("total_personalaufwand", field).to_d - table.value_of("honorare", field).to_d
      end

      def direktkosten_for_topic(field)
        [
          table.value_of("raumaufwand", field).to_d,
          table.value_of("uebriger_sachaufwand", field).to_d,
          table.value_of("honorare", field).to_d
        ].sum
      end

      def total_personalaufwand_for_all_topics
        @total_personalaufwand_for_all_topics ||=
          self.class.topic_fields.sum { |field| personalaufwand_for_topic(field) }
      end

      def total_direktkosten_for_all_topics
        @total_direktkosten_for_all_topics ||=
          self.class.topic_fields.sum { |field| direktkosten_for_topic(field) }
      end
    end
  end
end
