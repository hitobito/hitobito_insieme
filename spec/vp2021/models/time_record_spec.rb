# frozen_string_literal: true

#  Copyright (c) 2021, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe TimeRecord do
  let(:year) { 2021 }

  let(:record) do
    TimeRecord.new(group: groups(:be), year: year,
                   total_lufeb_general: 1,
                   total_media: 2,
                   total_lufeb_specific: 3,
                   total_lufeb_promoting: 4,
                   blockkurse: 5,
                   tageskurse: 6,
                   jahreskurse: 7,
                   treffpunkte: 8,
                   beratung: 9,
                   mittelbeschaffung: 10,
                   verwaltung: 11,
                   nicht_art_74_leistungen: 12,

                   # lufeb general
                   auskuenfte: 13,
                   referate: 14,
                   medien_zusammenarbeit: 15,
                   sensibilisierungskampagnen: 16,

                   # media
                   medien_grundlagen: 17,
                   website: 18,
                   newsletter: 19,
                   videos: 20,
                   social_media: 21,
                   beratungsmodule: 22,
                   apps: 23,

                   # lufeb_specific
                   erarbeitung_grundlagen: 24,
                   gremien: 25,
                   vernehmlassungen: 26,
                   projekte: 27,

                   # lufeb_promoting
                   beratung_fachhilfeorganisationen: 28,
                   unterstuetzung_leitorgane: 29,
                   freiwilligen_akquisition: 30
                  )
  end

  context 'calculated totals' do
    context '#total_lufeb' do
      it 'is 0 for new record' do
        expect(TimeRecord.new.total_lufeb).to eq(0)
      end

      it 'is the sum the values set' do
        expect(record.total_lufeb).to eq 8
      end
    end

    context '#total_courses' do
      it 'is 0 for new record' do
        expect(TimeRecord.new.total_courses).to eq(0)
      end

      it 'is the sum the values set' do
        expect(record.total_courses).to eq 26
      end
    end

    context '#total_additional_person_specific' do
      it 'is 0 for new record' do
        expect(TimeRecord.new.total_additional_person_specific).to eq(0)
      end

      it 'is the sum the values set' do
        expect(record.total_additional_person_specific).to eq 9
      end
    end

    context '#total_remaining' do
      it 'is 0 for new record' do
        expect(TimeRecord.new.total_remaining).to eq(0)
      end

      it 'is the sum the values set' do
        expect(record.total_remaining).to eq 21
      end
    end

    context '#total_paragraph_74' do
      it 'is 0 for new record' do
        expect(TimeRecord.new.total_paragraph_74).to eq(0)
      end

      it 'is the sum the values set' do
        expect(record.total_paragraph_74).to eq 66
      end
    end

    context '#total_not_paragraph_74' do
      it 'is 0 for new record' do
        expect(TimeRecord.new.total_not_paragraph_74).to eq(0)
      end

      it 'is the sum the values set' do
        expect(record.total_not_paragraph_74).to eq 12
      end
    end
  end

  context 'stored totals' do
    context '#update_totals' do
      it 'is called on save' do
        expect(record).to receive(:update_totals)

        record.type = 'TimeRecord::EmployeeTime'
        record.save!
      end
    end

    [[:total_lufeb_general, 58],
     [:total_lufeb_private, nil],
     [:total_lufeb_specific, 102],
     [:total_lufeb_promoting, 87],
     [:total_media, 140],
     [:total, 455]].each do |method, value|
      context "##{method}" do
        if method == :total
          it 'is 0 for new record before save' do
            expect(TimeRecord.new.send(method)).to eq 0
          end
        else
          it 'is nil for new record before save' do
            expect(TimeRecord.new.send(method)).to be_nil
          end
        end

        it 'is 0 for new record after save' do
          new_record = TimeRecord.new(group: groups(:be), year: year, type: 'TimeRecord::EmployeeTime')
          new_record.save!
          expected = value.present? ? 0 : nil
          expect(new_record.send(method)).to eq(expected)
        end

        it 'is the correct sum for nonempty record' do
          record.type = 'TimeRecord::EmployeeTime'
          record.save!
          expect(record.send(method)).to eq(value)
        end
      end
    end
  end

  context 'pensums' do
    it 'exists a bsv_hours_per_year reporting parameter' do
      expect(ReportingParameter.for(year).bsv_hours_per_year).to eq 1900
    end

    context '#total_paragraph_74_pensum' do
      it 'is 0 for new record' do
        expect(TimeRecord.new(year: year).total_paragraph_74_pensum).to eq(0)
      end

      it 'is the equivalent to 100%-jobs' do
        expect(record.total_paragraph_74).to eq 66
        expect(record.total_paragraph_74_pensum).to eq 66.to_d / 1900
      end
    end

    context '#total_not_paragraph_74_pensum' do
      it 'is 0 for new record' do
        expect(TimeRecord.new(year: year).total_not_paragraph_74_pensum).to eq(0)
      end

      it 'is the equivalent to 100%-jobs' do
        expect(record.total_not_paragraph_74).to eq 12
        expect(record.total_not_paragraph_74_pensum).to eq 12.to_d / 1900
      end
    end

    context '#total_pensum' do
      it 'is 0 for new record before save' do
        expect(TimeRecord.new(year: year).total_pensum).to eq(0)
      end

      it 'is 0 for new record after save' do
        new_record = TimeRecord.new(group: groups(:be), year: year, type: 'TimeRecord::EmployeeTime')
        new_record.save!
        expect(new_record.total_pensum).to eq(0)
      end

      it 'is the equivalent to 100%-jobs' do
        record.type = 'TimeRecord::EmployeeTime'
        record.save!
        expect(record.total).to eq 455
        expect(record.total_pensum).to eq 455.to_d / 1900
      end
    end

  end
end
