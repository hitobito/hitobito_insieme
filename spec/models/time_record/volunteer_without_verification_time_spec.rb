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

describe TimeRecord::VolunteerWithoutVerificationTime do

  context '#update_totals' do
    it 'does not calls the lufeb calculation methods on save' do
      record = TimeRecord::VolunteerWithoutVerificationTime.new(year: 2014, group: groups(:be))
      expect(record).not_to receive(:calculate_total_lufeb_general)
      expect(record).not_to receive(:calculate_total_lufeb_private)
      expect(record).not_to receive(:calculate_total_lufeb_specific)
      expect(record).not_to receive(:calculate_total_lufeb_promoting)
      expect(record).to receive(:calculate_total)
      record.save!
    end

    it 'uses the manual lufeb subtotals to calculate the total' do
      record = TimeRecord::VolunteerWithoutVerificationTime.new(year: 2014,
                                                                group: groups(:be),
                                                                total_lufeb_general: 1,
                                                                total_lufeb_private: 2,
                                                                total_lufeb_specific: 3,
                                                                total_lufeb_promoting: 4)



      expect(record.total_lufeb_general).to eq 1
      expect(record.total_lufeb_private).to eq 2
      expect(record.total_lufeb_specific).to eq 3
      expect(record.total_lufeb_promoting).to eq 4
      expect(record.total).to eq nil

      record.save!

      expect(record.total_lufeb_general).to eq 1
      expect(record.total_lufeb_private).to eq 2
      expect(record.total_lufeb_specific).to eq 3
      expect(record.total_lufeb_promoting).to eq 4
      expect(record.total).to eq 10
    end
  end

end
