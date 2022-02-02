# encoding: utf-8

#  Copyright (c) 2012-2021, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Event::CourseRecord do
  let(:group) { groups(:be) }
  let(:year) { 2021 }

  def new_record(event, attrs = {})
    event.course_record.try(:destroy!)
    r = Event::CourseRecord.new(attrs.merge(event: event, year: year))
    r.valid?
    r
  end

  context 'treffpunkt courses' do
    let(:event) do
      event = Fabricate(:course, groups: [group], leistungskategorie: 'tp', fachkonzept: 'treffpunkt')
      event.dates = [
        Fabricate(:event_date, start_at: Date.new(2021, 3, 16))
      ]
      event
    end

    subject(:record) do
      new_record(event, {
        betreuerinnen: 2,
        kursdauer: 2,
        honorare_inkl_sozialversicherung: 60, # -> direkter_aufwand
        gemeinkostenanteil: 20
      })
    end

    it 'calculates vollkosten pro betreuungsstunde' do
      expect(record.year).to eq 2021
      expect(record.betreuungsstunden).to eq(4.to_d)
      expect(record.vollkosten_pro_betreuungsstunde).to eq(20.to_d)
    end

    it 'handles division by zero' do
      record.betreuerinnen = 0
      record.set_cached_values # trigger before-validation hook to update values

      expect(record.year).to eq 2021
      expect(record.vollkosten_pro_betreuungsstunde).to eq(0.to_d)
    end
  end

  context 'treffpunkt aggregate courses' do
    let(:event) do
      event = Fabricate(:aggregate_course, groups: [group], leistungskategorie: 'tp', fachkonzept: 'treffpunkt')
      event.dates = [
        Fabricate(:event_date, start_at: Date.new(2021, 3, 16))
      ]
      event
    end

    subject(:record) do
      new_record(event, {
        betreuerinnen: 2,
        kursdauer: 2,
        betreuungsstunden: 4,
        honorare_inkl_sozialversicherung: 60, # -> direkter_aufwand
        gemeinkostenanteil: 20
      })
    end

    it 'calculates vollkosten pro betreuungsstunde' do
      expect(subject.year).to eq 2021
      expect(subject.betreuungsstunden).to eq(4.to_d)
      expect(subject.direkter_aufwand).to eq(60)
      expect(subject.gemeinkostenanteil).to eq(20)
      expect(subject.total_vollkosten).to eq(80.to_d)
      expect(subject.vollkosten_pro_betreuungsstunde).to eq(20.to_d)
    end

    it 'handles division by zero' do
      record.betreuungsstunden = 0
      expect(record.year).to eq 2021
      expect(record.vollkosten_pro_betreuungsstunde).to eq(0.to_d)
    end
  end
end
