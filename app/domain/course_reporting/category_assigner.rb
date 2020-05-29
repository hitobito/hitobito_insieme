# frozen_string_literal: true
#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module CourseReporting
  class CategoryAssigner

    attr_reader :record

    def initialize(course_record)
      @record = course_record
    end

    def compute
      if !all_information_present? || record.sk?
        1
      else
        send("category_from_input_#{record.inputkriterien}")
      end
    end

    def all_information_present?
      Event::CourseRecord::INPUTKRITERIEN.include?(record.inputkriterien) &&
      record.year? &&
      (record.sk? || globals)
    end

    private

    def category_from_input_a
      1
    end

    def category_from_input_b
      if record.vollkosten_pro_le >= schwelle_1
        2
      else
        1
      end
    end

    def category_from_input_c
      if record.vollkosten_pro_le > schwelle_2
        3
      elsif record.vollkosten_pro_le >= schwelle_1
        2
      else
        1
      end
    end

    def schwelle_1
      if record.bk?
        globals.vollkosten_le_schwelle1_blockkurs.to_d
      elsif record.tk?
        globals.vollkosten_le_schwelle1_tageskurs.to_d
      else
        fail NotImplementedError
      end
    end

    def schwelle_2
      if record.bk?
        globals.vollkosten_le_schwelle2_blockkurs.to_d
      elsif record.tk?
        globals.vollkosten_le_schwelle2_tageskurs.to_d
      else
        fail NotImplementedError
      end
    end

    def globals
      @globals ||= ReportingParameter.for(record.year)
    end
  end
end
