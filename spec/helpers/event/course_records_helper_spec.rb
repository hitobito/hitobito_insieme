# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Event::CourseRecordsHelper do

  include FormatHelper
  include UtilityHelper
  include LayoutHelper

  context 'inline help text' do

    let(:form)  { StandardFormBuilder.new(:entry, entry, self, {}) }
    before { event.build_course_record }

    context 'aggregate course' do

      let(:event) { Fabricate(:aggregate_course, leistungskategorie: 'sk', fachkonzept: 'sport_jugend') }
      let(:entry) { Event::CourseRecordDecorator.new(event.course_record) }

      it 'does not show inline help text if aggregate course' do
        field = participant_field_with_suggestion(form, :teilnehmende, '42')
        readonly_value = participant_readonly_value_with_suggestion(form, :total, '33', '22')
        kursdauer = kursdauer_field(form, :kursdauer)
        expect(field).not_to match(/<span class="muted">gemäss TN-Liste/)
        expect(readonly_value).not_to match(/<span class="help-inline">gemäss TN-Liste/)
        expect(kursdauer).not_to match(/<span class="muted">gemäss Kursdaten/)
      end

    end

    context 'course "sammelkurs"' do

      let(:event) { Fabricate(:course, leistungskategorie: 'sk', fachkonzept: 'sport_jugend') }
      let(:entry) { Event::CourseRecordDecorator.new(event.course_record) }

      it 'shows inline help text if course' do
        @numbers = CourseReporting::CourseNumbers.new(event)
        field = participant_field_with_suggestion(form, :teilnehmende, '42')
        readonly_value = participant_readonly_value_with_suggestion(form, :total, '33', '22')
        kursdauer = kursdauer_field(form, :kursdauer)
        expect(field).to match(/<span class="muted">gemäss TN-Liste/)
        expect(readonly_value).to match(/<span class="help-inline">gemäss TN-Liste/)
        expect(kursdauer).to match(/<span class="muted">gemäss Kursdaten/)
      end

    end

    context 'course "treffpunkt"' do

      let(:event) { Fabricate(:course, leistungskategorie: 'tp', fachkonzept: 'treffpunkt') }
      let(:entry) { Event::CourseRecordDecorator.new(event.course_record) }

      it 'shows inline help text if course' do
        @numbers = CourseReporting::CourseNumbers.new(event)
        field = participant_field_with_suggestion(form, :teilnehmende, '42')
        readonly_value = participant_readonly_value_with_suggestion(form, :total, '33', '22')
        kursdauer = kursdauer_field(form, :kursdauer)
        expect(field).to match(/<span class="muted">gemäss TN-Liste/)
        expect(readonly_value).to match(/<span class="help-inline">gemäss TN-Liste/)
        expect(kursdauer).to match(/<span class="muted">inkl. 1h Vor- und Nachbereitung/)
      end

    end
  end

end
