# frozen_string_literal: true

#  Copyright (c) 2022, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Fp2022::TimeRecord::Calculation do
  let(:year) { 2022 }

  let(:record) do
    TimeRecord.new(
      group: groups(:be), year: year,
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
      freiwilligen_akquisition: 30,

      # lufeb_grundlagen
      lufeb_grundlagen: 31,
    )
  end

  subject { described_class.new(record) }

  it 'total_lufeb' do
    expect(subject.total_lufeb).to eq 39
  end

  it 'total_media' do
    expect(subject.total_media).to eq 2
  end

  it 'total_lufeb_grundlagen' do
    expect(subject.total_lufeb_grundlagen).to eq 31
  end

  it 'total_courses' do
    expect(subject.total_courses).to eq 26
  end

  it 'total_additional_person_specific' do
    expect(subject.total_additional_person_specific).to eq 9
  end

  it 'total_remaining' do
    expect(subject.total_remaining).to eq 21
  end

  it 'total_paragraph_74' do
    expect(subject.total_paragraph_74).to eq 97
  end
  it 'total_paragraph_74_pensum' do
    expect(subject.total_paragraph_74_pensum).to eq 97.to_d / 1900
  end

  it 'total_not_paragraph_74' do
    expect(subject.total_not_paragraph_74).to eq 12
  end
  it 'total_not_paragraph_74_pensum' do
    expect(subject.total_not_paragraph_74_pensum).to eq 12.to_d / 1900
  end

  it 'total_pensum' do
    expect(subject.total_pensum).to eq (12 + 97).to_d / 1900
  end

  it 'update_totals' do
    expect(subject.total_lufeb_general).to eq 1
    expect(subject.total_lufeb_specific).to eq 3
    expect(subject.total_lufeb_promoting).to eq 4
    expect(subject.total_media).to eq 2

    subject.update_totals

    expect(subject.total_lufeb_general).to eq 58
    expect(subject.total_lufeb_specific).to eq 102
    expect(subject.total_lufeb_promoting).to eq 87
    expect(subject.total_media).to eq 140
  end
end
