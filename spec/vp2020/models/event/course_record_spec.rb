# encoding: utf-8

#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Event::CourseRecord do

  let(:group) { groups(:be) }

  def new_record(event, attrs = {})
    event.course_record.try(:destroy!)
    r = Event::CourseRecord.new(attrs.merge(event: event))
    r.valid?
    r
  end

  context 'treffpunkt courses' do
    let(:event) do
      event = Fabricate(:course, groups: [group], leistungskategorie: 'tp', fachkonzept: 'treffpunkt')
      event.dates = [
        Fabricate(:event_date, start_at: Date.new(2020, 3, 16))
      ]
      event
    end
    let(:record) do
      new_record(event)
    end

    before do
      record.betreuerinnen = 2
      record.kursdauer = 2
      record.direkter_aufwand = 60
      record.gemeinkostenanteil = 20
    end

    it 'calculates vollkosten pro betreuungsstunde' do
      expect(record.year).to eq 2020
      expect(record.vollkosten_pro_betreuungsstunde).to eq(20.to_d)
    end

    it 'handles division by zero' do
      record.betreuerinnen = 0
      expect(record.year).to eq 2020
      expect(record.vollkosten_pro_betreuungsstunde).to eq(0.to_d)
    end
  end

  context 'treffpunkt aggregate courses' do
    let(:event) do
      event = Fabricate(:aggregate_course, groups: [group], leistungskategorie: 'tp', fachkonzept: 'treffpunkt')
      event.dates = [
        Fabricate(:event_date, start_at: Date.new(2020, 3, 16))
      ]
      event
    end
    let(:record) do
      new_record(event)
    end

    before do
      record.betreuerinnen = 2
      record.kursdauer = 2
      record.betreuungsstunden = 4
      record.direkter_aufwand = 60
      record.gemeinkostenanteil = 20
    end

    it 'calculates vollkosten pro betreuungsstunde' do
      expect(record.year).to eq 2020
      expect(record.vollkosten_pro_betreuungsstunde).to eq(20.to_d)
    end

    it 'handles division by zero' do
      record.betreuungsstunden = 0
      expect(record.year).to eq 2020
      expect(record.vollkosten_pro_betreuungsstunde).to eq(0.to_d)
    end

  end

end
