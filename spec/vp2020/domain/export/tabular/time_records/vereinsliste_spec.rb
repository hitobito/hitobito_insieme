# frozen_string_literal: true

#  Copyright (c) 2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Vp2020::Export::Tabular::TimeRecords::Vereinsliste do

  let(:year) { 2020 }
  let(:type) { TimeRecord::EmployeeTime.sti_name }

  context 'without records' do
    context 'for employee time' do
      it 'contains correct headers' do
        labels = described_class.new(vp_class('TimeRecord::Vereinsliste').new(year, type)).labels
        expect(labels).to match_array [
          'Gruppe',
          'Grundlagenarbeit zu LUFEB',
          'Information / Beratung von Organisationen und Einzelpersonen',
          'Unterstützung von Menschen mit Behinderungen in Leitorganen',
          'Akquisition von Freiwilligen',
          'Förderung der Selbsthilfe / Unterstützung von Selbsthilfeorganisationen und -gruppen sowie Einzelpersonen',
          'Auskünfte an die Öffentlichkeit, Menschen mit Behinderung, Angehörige, Fachpersonen, Medien',
          'Vorträge / Referate',
          'Zusammenarbeit mit Medien',
          'Sensibilisierungs- und Entstigmatisierungsarbeiten resp. -veranstaltungen',
          'Allgemeine Medien- und Öffentlichkeitsarbeit',
          'Grundlagenarbeit (Arbeitsinstrumente, Konzepte, Studien, Grundlagenpapiere)',
          'Mitgliedschaft / Mitarbeit in Gremien',
          'Mitarbeit bei Vernehmlassungen',
          'Projekte Art. 74 (Vorbereitung und Durchführung)',
          'Themenspezifische Grundlagenarbeit / Projekte',
          'Total LUFEB-Leistungen',
          'Grundlagenarbeit zu Medien & Publikationen',
          'Website',
          'Rundbriefe, Broschüren, Merkblätter',
          'Videos',
          'Soziale Medien',
          'Standardisierte Beratungsmodule',
          'Applikationen',
          'Medien & Publikationen',
          'Grundlagenarbeit zu Kursen & Treffpunkten',
          'Blockkurse',
          'Tageskurse',
          'Semester-/Jahreskurse',
          'Treffpunkte',
          'Total Kurse',
          'Sozialberatung',
          'Total Weitere personenspezifische Leistungen',
          'Mittelbeschaffung',
          'Vereinsführung und Verwaltung',
          'Total übrige Leistungen',
          'Total Art. 74 betreffend',
          'Total Art. 74 nicht betreffend',
          'Total'
        ]
      end
    end

    context 'for volunteer without verification time' do

      let(:type) { TimeRecord::VolunteerWithoutVerificationTime.sti_name }

      it 'contains correct headers' do
        labels = described_class.new(vp_class('TimeRecord::Vereinsliste').new(year, type)).labels
        expect(labels).to match_array [
          'Gruppe',
          'Grundlagenarbeit zu LUFEB',
          'Förderung der Selbsthilfe / Unterstützung von Selbsthilfeorganisationen und -gruppen sowie Einzelpersonen',
          'Allgemeine Medien- und Öffentlichkeitsarbeit',
          'Themenspezifische Grundlagenarbeit / Projekte',
          'Total LUFEB-Leistungen',
          'Grundlagenarbeit zu Medien & Publikationen',
          'Website',
          'Rundbriefe, Broschüren, Merkblätter',
          'Videos',
          'Soziale Medien',
          'Standardisierte Beratungsmodule',
          'Applikationen',
          'Medien & Publikationen',
          'Grundlagenarbeit zu Kursen & Treffpunkten',
          'Blockkurse',
          'Tageskurse',
          'Semester-/Jahreskurse',
          'Treffpunkte',
          'Total Kurse',
          'Sozialberatung',
          'Total Weitere personenspezifische Leistungen',
          'Mittelbeschaffung',
          'Vereinsführung und Verwaltung',
          'Total übrige Leistungen',
          'Total Art. 74 betreffend',
          'Total Art. 74 nicht betreffend',
          'Total'
        ]
      end

    end

    it 'contains no data' do
      rows = export
      expect(rows[0]).to match_array ['insieme Schweiz',
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil,
        nil, nil, nil
      ]
    end
  end

  context 'with records' do
    before do
      TimeRecord::EmployeeTime.create!(
        group: groups(:be), year: year, eigene_zeitschriften: 200, eigene_webseite: 330, blockkurse: 300,
        nicht_art_74_leistungen: 50,
        employee_pensum_attributes: { paragraph_74: 1.5, not_paragraph_74: 0.5 })
      TimeRecord::EmployeeTime.create!(
        group: groups(:fr), year: year, eigene_zeitschriften: 100, eigene_webseite: 230, blockkurse: 200,
        nicht_art_74_leistungen: 00)
      TimeRecord::VolunteerWithVerificationTime.create!(
        group: groups(:be), year: year, kontakte_medien: 100, blockkurse: 400, verwaltung: 88,
        nicht_art_74_leistungen: 50)
      TimeRecord::VolunteerWithoutVerificationTime.create!(
        group: groups(:be), year: year, total_lufeb_general: 300, tageskurse: 55,
        nicht_art_74_leistungen: 50)
    end

    context 'for employee time' do
      it 'contains all data' do
        data = export
        expect(data[2]).to eq(["Kanton Bern",
                               nil, nil, nil, nil, 0,
                               nil, nil, nil, nil, 0,
                               nil, nil, nil, nil, 0, 0,
                               nil, nil, nil, nil, nil, nil, nil, 0,
                               nil, 300, nil, nil, nil, 300, nil, 0, nil, nil, 0,
                               300, 50, 350])
      end

      it 'includes externe organisation' do
        external_group = Group.create!(parent: groups(:dachverein),
                                       name: 'externa',
                                       type: Group::ExterneOrganisation.sti_name)
        TimeRecord::EmployeeTime.create!(
          group: external_group, year: year, eigene_zeitschriften: 42, eigene_webseite: 230, blockkurse: 200,
          nicht_art_74_leistungen: 00)
        data = export

        expect(data.last.first).to eq('externa')
      end
    end

    context 'for volunteer wthout verification time' do

      let(:type) { TimeRecord::VolunteerWithoutVerificationTime.sti_name }

      it 'contains all data' do
        data = export
        expect(data[2]).to match_array(['Kanton Bern',
                               nil,
                               nil,
                               300,
                               nil,
                               300, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 55, nil, nil, 55, nil, 0, nil, nil, 0,
                               355, 50, 405])
      end
    end

  end

  def export
    exporter = described_class.new(vp_class('TimeRecord::Vereinsliste').new(year, type))
    exporter.data_rows.to_a
  end

end
