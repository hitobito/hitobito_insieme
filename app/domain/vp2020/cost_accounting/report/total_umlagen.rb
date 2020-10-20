# frozen_string_literal: true

#  Copyright (c) 2012-2014, 2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2020::CostAccounting
  module Report
    # Gemeinkosten
    class TotalUmlagen < Subtotal

      self.total_includes_gemeinkostentraeger = false

      self.summed_reports = %w(
        umlage_mittelbeschaffung

        total_personalaufwand
        raumaufwand
        uebriger_sachaufwand
        abschreibungen
      )

      self.summed_fields = %w(
        mittelbeschaffung
        verwaltung
        raeumlichkeiten
      )

      # this deviates from a "normal" subtotal as specific field are calculated
      # with specific quotas derived from other specific field.
      #
      # The quota is determined in relation to the personalaufwand.
      #
      # This meta-programming to define both the single field and the sum of
      # all fields seems like the most maintainable/readable version.
      %w(
        beratung
        medien_und_publikationen
        treffpunkte
        blockkurse
        tageskurse
        jahreskurse
        lufeb
      ).each do |field|
        define_method(field) do # one field
          gemeinkostentraeger * gemeinkosten_quota(field).to_d
        end
      end.tap do |fields| # rubocop:disable Style/MultilineBlockChain
        define_method :total_personalaufwand_for_all_topics do # sum of all fields
          @total_personalaufwand_for_all_topics ||= fields.sum do |field|
            table.value_of('total_personalaufwand', field)
          end
        end
      end

      define_summed_field_methods

      def aufwand_ertrag_ko_re
        nil
      end

      private

      def gemeinkosten_quota(field)
        personalaufwand_for_topic = table.value_of('total_personalaufwand', field)
        return 0 if personalaufwand_for_topic.zero? || total_personalaufwand_for_all_topics.zero?

        personalaufwand_for_topic / total_personalaufwand_for_all_topics
      end

    end
  end
end
