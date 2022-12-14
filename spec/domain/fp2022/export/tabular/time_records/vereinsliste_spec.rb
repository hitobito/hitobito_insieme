# frozen_string_literal: true

#  Copyright (c) 2022, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Fp2022::Export::Tabular::TimeRecords::Vereinsliste do

  let(:year) { 2022 }
  let(:type) { TimeRecord::EmployeeTime.sti_name }

  context 'without records' do
    context 'for employee time' do
      it 'contains correct headers' do
        labels = described_class.new(fp_class('TimeRecord::Vereinsliste').new(year, type)).labels
        expected_labels = [
          'Gruppe',
          'Grundlagenarbeit zu LUFEB',
          'Information / Beratung von Organisationen und Einzelpersonen',
          'Unterstützung von Menschen mit Behinderungen in Leitorganen',
          'Akquisition von Freiwilligen',
          'Förderung der Selbsthilfe',
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
          'Grundlagenarbeit zu Kursen',
          'Blockkurse',
          'Tageskurse',
          'Semester-/Jahreskurse',
          'Grundlagenarbeit zu Treffpunkten',
          'Treffpunkte',
          'Total Kurse & Treffpunkte',
          'Sozialberatung (inkl. Grundlagenarbeit)',
          'Mittelbeschaffung',
          'Vereinsführung und Verwaltung',
          'Total übrige Leistungen',
          'Total Art. 74 betreffend',
          'Total Art. 74 nicht betreffend',
          'Total'
        ]
        expect(labels).to match_array expected_labels
        expect(labels).to eq expected_labels
      end
    end

    context 'for volunteer without verification time' do

      let(:type) { TimeRecord::VolunteerWithoutVerificationTime.sti_name }

      it 'contains correct headers' do
        labels = described_class.new(fp_class('TimeRecord::Vereinsliste').new(year, type)).labels
        expected_labels = [
          'Gruppe',
          'Grundlagenarbeit zu LUFEB',
          'Förderung der Selbsthilfe',
          'Allgemeine Medien- und Öffentlichkeitsarbeit',
          'Themenspezifische Grundlagenarbeit / Projekte',
          'Total LUFEB-Leistungen',
          'Medien & Publikationen',
          'Grundlagenarbeit zu Kursen',
          'Blockkurse',
          'Tageskurse',
          'Semester-/Jahreskurse',
          'Grundlagenarbeit zu Treffpunkten',
          'Treffpunkte',
          'Total Kurse & Treffpunkte',
          'Sozialberatung (inkl. Grundlagenarbeit)',
          'Mittelbeschaffung',
          'Vereinsführung und Verwaltung',
          'Total übrige Leistungen',
          'Total Art. 74 betreffend',
          'Total Art. 74 nicht betreffend',
          'Total'
        ]
        expect(labels).to match_array expected_labels
        expect(labels).to eq expected_labels
      end

    end

    it 'contains no data' do
      rows = export
      expect(rows[0]).to match_array ['insieme Schweiz',
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil,
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
                               nil, 300,
                               nil, nil, nil, nil, 300,
                               nil,
                               nil, nil, 0,
                               300, 50,
                               350])
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

      let(:labels) { described_class.new(fp_class('TimeRecord::Vereinsliste').new(year, type)).labels }
      let(:empty_row) { labels.zip(Array(labels.size)).to_h }

      it 'contains all data' do
        data = export
        expect(labels.zip(data[2]).to_h).to eq empty_row.merge({
          "Gruppe" => 'Kanton Bern',

          "Allgemeine Medien- und Öffentlichkeitsarbeit" => 300,
          "Total LUFEB-Leistungen" => 300,

          "Tageskurse" => 55,
          "Total Kurse & Treffpunkte" => 55,

          "Total übrige Leistungen" => 0,
          "Total Art. 74 betreffend" => 355,
          "Total Art. 74 nicht betreffend" => 50,

          "Total"  => 405
        })
      end
    end

  end

  def export
    exporter = described_class.new(fp_class('TimeRecord::Vereinsliste').new(year, type))
    exporter.data_rows.to_a
  end

end
