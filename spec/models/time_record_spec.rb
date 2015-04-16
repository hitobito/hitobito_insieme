# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# == Schema Information
#
# Table name: time_records
#
#  id                                       :integer          not null, primary key
#  group_id                                 :integer          not null
#  year                                     :integer          not null
#  verwaltung                               :integer
#  beratung                                 :integer
#  treffpunkte                              :integer
#  blockkurse                               :integer
#  tageskurse                               :integer
#  jahreskurse                              :integer
#  kontakte_medien                          :integer
#  interviews                               :integer
#  publikationen                            :integer
#  referate                                 :integer
#  medienkonferenzen                        :integer
#  informationsveranstaltungen              :integer
#  sensibilisierungskampagnen               :integer
#  auskunftserteilung                       :integer
#  kontakte_meinungsbildner                 :integer
#  beratung_medien                          :integer
#  eigene_zeitschriften                     :integer
#  newsletter                               :integer
#  informationsbroschueren                  :integer
#  eigene_webseite                          :integer
#  erarbeitung_instrumente                  :integer
#  erarbeitung_grundlagen                   :integer
#  projekte                                 :integer
#  vernehmlassungen                         :integer
#  gremien                                  :integer
#  vermittlung_kontakte                     :integer
#  unterstuetzung_selbsthilfeorganisationen :integer
#  koordination_selbsthilfe                 :integer
#  treffen_meinungsaustausch                :integer
#  beratung_fachhilfeorganisationen         :integer
#  unterstuetzung_behindertenhilfe          :integer
#  mittelbeschaffung                        :integer
#  allgemeine_auskunftserteilung            :integer
#  type                                     :string(255)      not null
#  total_lufeb_general                      :integer
#  total_lufeb_private                      :integer
#  total_lufeb_specific                     :integer
#  total_lufeb_promoting                    :integer
#  nicht_art_74_leistungen                  :integer
#

require 'spec_helper'

describe TimeRecord do

  let(:record) do
    TimeRecord.new(year: 2014, total_lufeb_general: 1, total_lufeb_private: 2,
                   total_lufeb_specific: 3, total_lufeb_promoting: 4,
                   blockkurse: 5, tageskurse: 6, jahreskurse: 7,
                   treffpunkte: 8, beratung: 9,
                   mittelbeschaffung: 10, verwaltung: 11,
                   nicht_art_74_leistungen: 12)
  end

  context 'totals' do
    context '#total_lufeb' do
      it 'is 0 for new record' do
        expect(TimeRecord.new.total).to eq(0)
      end

      it 'is the sum the values set' do
        expect(record.total_lufeb).to eq 10
      end
    end

    context '#total_courses' do
      it 'is 0 for new record' do
        expect(TimeRecord.new.total_courses).to eq(0)
      end

      it 'is the sum the values set' do
        expect(record.total_courses).to eq 18
      end
    end

    context '#total_additional_person_specific' do
      it 'is 0 for new record' do
        expect(TimeRecord.new.total_additional_person_specific).to eq(0)
      end

      it 'is the sum the values set' do
        expect(record.total_additional_person_specific).to eq 17
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

    context '#total' do
      it 'is 0 for new record' do
        expect(TimeRecord.new.total).to eq(0)
      end

      it 'is the sum the values set' do
        expect(record.total).to eq 78
      end
    end
  end

  context 'pensums' do
    it 'exists a bsv_hours_per_year reporting parameter' do
      expect(ReportingParameter.for(2014).bsv_hours_per_year).to eq 1900
    end

    context '#total_paragraph_74_pensum' do
      it 'is 0 for new record' do
        expect(TimeRecord.new(year: 2014).total_paragraph_74_pensum).to eq(0)
      end

      it 'is the equivalent to 100%-jobs' do
        expect(record.total_paragraph_74_pensum).to eq 66.to_d / 1900
      end
    end

    context '#total_not_paragraph_74_pensum' do
      it 'is 0 for new record' do
        expect(TimeRecord.new(year: 2014).total_not_paragraph_74_pensum).to eq(0)
      end

      it 'is the equivalent to 100%-jobs' do
        expect(record.total_not_paragraph_74_pensum).to eq 12.to_d / 1900
      end
    end

    context '#total_pensum' do
      it 'is 0 for new record' do
        expect(TimeRecord.new(year: 2014).total_pensum).to eq(0)
      end

      it 'is the equivalent to 100%-jobs' do
        expect(record.total_pensum).to eq 78.to_d / 1900
      end
    end

  end

end
