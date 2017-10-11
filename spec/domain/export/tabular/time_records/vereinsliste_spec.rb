# encoding: utf-8

#  Copyright (c) 2016, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Export::Tabular::TimeRecords::Vereinsliste do

  let(:year) { 2014 }
  let(:type) { TimeRecord::EmployeeTime.sti_name }

  context 'without records' do
    context 'for employee time' do
      it 'contains correct headers' do
        labels = described_class.new(TimeRecord::Vereinsliste.new(year, type)).labels
        expect(labels).to eq ['Gruppe',
                              'Kontakte zu Medien, zu Medienschaffenden',
                              'Erteilen von Interviews',
                              'Publikation',
                              'Vorträge, Referate',
                              'Medienkonferenzen',
                              'Informationsveranstaltungen',
                              'Sensibilisierungs- und Entstigmatisierungskampagnen',
                              'Allgemeine Auskunftserteilung und Triage',
                              'Kontakte zu MeinungsbildnerInnen',
                              'Beratung von Medienschaffenden',
                              'Allgemeine Medien- und Öffentlichkeitsarbeit',
                              'Eigene Zeitschriften',
                              'Periodisch erscheinende Rundbriefe / Newsletter',
                              'Informationsbroschüren, Informationsblätter, Merkblätter',
                              'Eigene Website und Social Media',
                              'Eigene öffentlich zugängliche Medien und Publikationen',
                              'Erarbeiten von Arbeitsinstrumenten und Konzepten',
                              'Erarbeiten von qualitativen Grundlagen',
                              'Initiierung, Leitung und Durchführung von Projekten',
                              'Mitarbeit bei Vernehmlassungen',
                              'Mitgliedschaft bzw. Mitarbeit in Gremien',
                              'Themenspezifische Grundlagenarbeit / Projekte',
                              'Auskunftserteilung / Kurzberatung',
                              'Vermittlung von Kontakten',
                              'Beratung und fachliche Begleitung',
                              'Koordination von Selbsthilfeaktivitäten',
                              'Planung, Organisation und Durchführung von informellen Treffen',
                              'Information, Beratung von Fachhilfeorganisationen betreffend Förderung der Selbsthilfe',
                              'Unterstützung von Behinderten in den Leitorganen von Organisationen der privaten Behindertenhilfe',
                              'Förderung der Selbsthilfe / Unterstützung von Selbsthilfeorganisationen und -gruppen sowie Einzelpersonen',
                              'Total LUFEB-Leistungen',
                              'Blockkurse',
                              'Tageskurse',
                              'Semester-/Jahreskurse',
                              'Total Kurse',
                              'Betreuung in Treffpunkten',
                              'Sozialberatung',
                              'Total Weitere personenspezifische Leistungen',
                              'Vereinsführung und Verwaltung',
                              'Mittelbeschaffung',
                              'Total übrige Leistungen',
                              'Total Art. 74 betreffend',
                              'Total Art. 74 nicht betreffend',
                              'Total']
      end
    end

    context 'for volunteer without verification time' do

      let(:type) { TimeRecord::VolunteerWithoutVerificationTime.sti_name }

      it 'contains correct headers' do
        labels = described_class.new(TimeRecord::Vereinsliste.new(year, type)).labels
        expect(labels).to eq ['Gruppe',
                              'Allgemeine Medien- und Öffentlichkeitsarbeit',
                              'Eigene öffentlich zugängliche Medien und Publikationen',
                              'Themenspezifische Grundlagenarbeit / Projekte',
                              'Förderung der Selbsthilfe / Unterstützung von Selbsthilfeorganisationen und -gruppen sowie Einzelpersonen',
                              'Total LUFEB-Leistungen',
                              'Blockkurse',
                              'Tageskurse',
                              'Semester-/Jahreskurse',
                              'Total Kurse',
                              'Betreuung in Treffpunkten',
                              'Sozialberatung',
                              'Total Weitere personenspezifische Leistungen',
                              'Vereinsführung und Verwaltung',
                              'Mittelbeschaffung',
                              'Total übrige Leistungen',
                              'Total Art. 74 betreffend',
                              'Total Art. 74 nicht betreffend',
                              'Total']
      end

    end

    it 'contains no data' do
      rows = export
      expect(rows[0]).to eq(['insieme Schweiz',
                             nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
                             nil, nil, nil, nil, nil,
                             nil, nil, nil, nil, nil, nil, nil,
                             nil, nil, nil, nil, nil, nil, nil, nil,
                             nil, nil, nil, nil, nil, nil, nil, nil, nil,
                             nil, nil, nil])
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
        expect(data[2]).to eq(['Kanton Bern',
                               nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 0,
                               200, nil, nil, 330, 530,
                               nil, nil, nil, nil, nil, 0,
                               nil, nil, nil, nil, nil, nil, nil, 0,
                               530, 300, nil, nil, 300, nil, nil, 0, nil, nil, 0,
                               830, 50, 880])
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
        expect(data[2]).to eq(['Kanton Bern',
                               300,
                               nil,
                               nil,
                               nil,
                               300, nil, 55, nil, 55, nil, nil, 0, nil, nil, 0,
                               355, 50, 405])
      end
    end

  end

  def export
    exporter = described_class.new(TimeRecord::Vereinsliste.new(year, type))
    exporter.data_rows.to_a
  end

end
