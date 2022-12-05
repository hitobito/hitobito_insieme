# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe 'TimeRecord::Report::VolunteerWithVerificationTime' do

  let(:year) { 2014 }
  let(:group) { groups(:be) }
  let(:table) { fp_class('TimeRecord::Table').new(group, year) }
  let(:report) { table.reports.fetch('volunteer_with_verification_time') }

  before do
    create_report(TimeRecord::VolunteerWithVerificationTime,
                  blockkurse: 3,
                  nicht_art_74_leistungen: 5)
  end

  context '#paragraph_74' do
    it 'calculates the correct value' do
      expect(report.paragraph_74).to eq 3.to_d / 1900
    end
  end

  context '#not_paragraph_74' do
    it 'calculates the correct value' do
      expect(report.not_paragraph_74).to eq 5.to_d / 1900
    end
  end

  context '#total' do
    it 'calculates the correct value' do
      expect(report.total).to eq 3.to_d / 1900 + 5.to_d / 1900
    end
  end

  def create_report(model_name, values)
    model_name.create!(values.merge(group_id: group.id, year: year))
  end
end
