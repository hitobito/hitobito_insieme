# encoding: utf-8

#  Copyright (c) 2017, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Insieme::Export::EventsExportJob do

  let(:filename) { Export::Event::Filename.new(group, event_filter.type, event_filter.year).to_s }
  subject { Export::EventsExportJob.new(:csv, person.id, group.id, event_filter.to_h, filename: filename) }

  let(:event_filter) { Event::Filter.new(group, type, 'all', 2012, false) }

  context 'dachverein' do
    let(:group) { groups(:dachverein) }
    let(:type) { 'Event::Course' }

    before do
      c = Fabricate(:course, groups: [group], kind: Event::Kind.first, leistungskategorie: 'bk', fachkonzept: 'sport_jugend')
      group.update!(vid: 42, bsv_number: '99')
      Fabricate(:event_date, event: c, start_at: Date.new(2012, 3, 5))
    end

    context 'top_leader' do
      let(:person) { people(:top_leader) }

      it 'creates detail export for cources' do
        expect(subject.exporter_class).to eq(Export::Tabular::Events::DetailList)
        expect(subject.filename).to start_with('course_vid42_bsv99_insieme-schweiz_2012')
        expect(subject.data).to be_present
      end
    end

    context 'vorstand' do
      let(:person) { Fabricate(:role, group: group, type: 'Group::Dachverein::Vorstandsmitglied').person }

      it 'creates detail export for cources' do
        expect(subject.exporter_class).to eq(Export::Tabular::Events::ShortList)
        expect(subject.filename).to start_with('course_vid42_bsv99_insieme-schweiz_2012')
        expect(subject.data).to be_present
      end
    end
  end

  context 'regionalverein' do
    let(:group) { groups(:be) }
    let(:type) { 'Event::AggregateCourse' }

    before do
      c = Fabricate(:course, groups: [group], kind: Event::Kind.first, leistungskategorie: 'bk', fachkonzept: 'sport_jugend')
      Fabricate(:aggregate_course, groups: [group], leistungskategorie: 'bk', fachkonzept: 'sport_jugend')
      Fabricate(:event_date, event: c, start_at: Date.new(2012, 3, 5))
    end

    context 'regio leader' do
      let(:person)  { people(:regio_leader) }

      it 'creates detail export for aggregate courses' do
        group.update!(vid: 42, bsv_number: '99')
        expect(subject.exporter_class).to eq Export::Tabular::Events::AggregateCourse::DetailList
        expect(subject.filename).to start_with('aggregate_course_vid42_bsv99_kanton-bern_2012')
      end
    end

    context 'vorstand' do
      let(:person) { Fabricate(:role, group: groups(:be), type: 'Group::Regionalverein::Vorstandsmitglied').person }

      it 'creates short export for aggregate courses' do
        group.update!(vid: 42, bsv_number: '99')
        expect(subject.exporter_class).to eq Export::Tabular::Events::AggregateCourse::ShortList
        expect(subject.filename).to start_with('aggregate_course_vid42_bsv99_kanton-bern_2012')
      end
    end

  end
end
