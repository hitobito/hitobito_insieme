# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe 'TimeRecord::Table' do

  let(:year)  { 2014 }
  let(:group) { groups(:be) }
  let(:table) { fp_class('TimeRecord::Table').new(group, year) }

  context '#value_of' do
    it 'is initialized without records' do
      errors = []
      excludes = %w(capital_substrate-paragraph_74)
      fp_class('TimeRecord::Table')::REPORTS.each do |report|
        fp_class('TimeRecord::Report::Base')::FIELDS.each do |field|
          next if excludes.include? "#{report.key}-#{field}"
          value = table.value_of(report.key, field).to_d
          if value != 0.0
            errors << "#{report.key}-#{field} is expected to be 0, got #{value}"
          end
        end
      end

      expect(errors).to be_blank, errors.join("\n")
    end
  end
end
