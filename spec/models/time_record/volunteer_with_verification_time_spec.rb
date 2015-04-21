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

describe TimeRecord::VolunteerWithVerificationTime do

  context '#update_totals' do
    it 'updates the lufeb subtotals on save' do
      record = TimeRecord::VolunteerWithVerificationTime.new(year: 2014,
                                                             group: groups(:be),
                                                             kontakte_medien: 1,
                                                             interviews: 2,
                                                             publikationen: 3,
                                                             referate: 4,
                                                             medienkonferenzen: 5,
                                                             informationsveranstaltungen: 6,
                                                             sensibilisierungskampagnen: 7,
                                                             allgemeine_auskunftserteilung: 8,
                                                             kontakte_meinungsbildner: 9,
                                                             beratung_medien: 10,
                                                             eigene_zeitschriften: 11,
                                                             newsletter: 12,
                                                             informationsbroschueren: 13,
                                                             eigene_webseite: 14,
                                                             erarbeitung_instrumente: 15,
                                                             erarbeitung_grundlagen: 16,
                                                             projekte: 17,
                                                             vernehmlassungen: 18,
                                                             gremien: 19,
                                                             auskunftserteilung: 20,
                                                             vermittlung_kontakte: 21,
                                                             unterstuetzung_selbsthilfeorganisationen: 22,
                                                             koordination_selbsthilfe: 23,
                                                             treffen_meinungsaustausch: 24,
                                                             beratung_fachhilfeorganisationen: 25,
                                                             unterstuetzung_behindertenhilfe: 26)
      expect(record.total_lufeb_general).to eq nil
      expect(record.total_lufeb_private).to eq nil
      expect(record.total_lufeb_specific).to eq nil
      expect(record.total_lufeb_promoting).to eq nil
      expect(record.total).to eq nil

      record.save!

      expect(record.total_lufeb_general).to eq 55
      expect(record.total_lufeb_private).to eq 50
      expect(record.total_lufeb_specific).to eq 85
      expect(record.total_lufeb_promoting).to eq 161
      expect(record.total).to eq 351
    end
  end

end
