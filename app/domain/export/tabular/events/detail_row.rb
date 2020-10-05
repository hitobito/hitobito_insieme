# frozen_string_literal: true

#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Export::Tabular::Events
  class DetailRow < Export::Tabular::Events::Row
    include Vertragsperioden::Domain

    delegate :year, to: :entry

    def initialize(*args)
      super

      course_record_methods = vp_class('Export::Tabular::Events::DetailList')::COURSE_RECORD_ATTRS
      methods_to_delegate = (course_record_methods - maybe_tp_method_mappings.keys)

      self.class.delegate(*methods_to_delegate, to: :course_record, allow_nil: true)
    end

    def total_tage_teilnehmende
      course_record&.send(maybe_tp_method(:total_tage_teilnehmende)).to_d
    end

    def vollkosten_pro_le
      course_record&.send(maybe_tp_method(:vollkosten_pro_le)).to_d
    end

    private

    def maybe_tp_method(attr_name)
      if course_record&.tp?
        maybe_tp_method_mappings.fetch(attr_name, attr_name)
      else
        attr_name
      end
    end

    def maybe_tp_method_mappings
      {
        total_tage_teilnehmende: :betreuungsstunden,
        vollkosten_pro_le: :vollkosten_pro_betreuungsstunde
      }
    end
  end
end
