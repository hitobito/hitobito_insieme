# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe TimeRecord::EmployeeTime do

  context '#update_lufeb_subtotals' do
    it 'updates the lufeb subtotals on save' do
      record = TimeRecord::EmployeeTime.new(year: 2014,
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

      record.save!

      expect(record.total_lufeb_general).to eq 55
      expect(record.total_lufeb_private).to eq 50
      expect(record.total_lufeb_specific).to eq 85
      expect(record.total_lufeb_promoting).to eq 161
    end
  end

end
