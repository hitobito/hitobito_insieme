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

class TimeRecord < ActiveRecord::Base

  belongs_to :group

  validates :year, uniqueness: { scope: [:group_id, :type] }
  validate :assert_group_has_reporting

  before_save :update_totals

  class << self
    def key
      name.demodulize.underscore
    end
  end

  def lufeb
    total_lufeb
  end

  def total_lufeb
    total_lufeb_general.to_i +
    total_lufeb_private.to_i +
    total_lufeb_specific.to_i +
    total_lufeb_promoting.to_i
  end

  def total_courses
    blockkurse.to_i +
    tageskurse.to_i +
    jahreskurse.to_i
  end

  def total_additional_person_specific
    treffpunkte.to_i +
    beratung.to_i
  end

  def total_remaining
    mittelbeschaffung.to_i +
    verwaltung.to_i
  end

  def total_paragraph_74
    @total_paragraph_74 ||=
      total_lufeb.to_i +
      total_courses.to_i +
      total_additional_person_specific.to_i +
      total_remaining.to_i
  end

  def total_not_paragraph_74
    nicht_art_74_leistungen.to_i
  end

  def total
    total_paragraph_74.to_i +
    total_not_paragraph_74.to_i
  end

  def total_paragraph_74_pensum
    total_paragraph_74.to_d / bsv_hours_per_year
  end

  def total_not_paragraph_74_pensum
    total_not_paragraph_74.to_d / bsv_hours_per_year
  end

  def total_pensum
    total.to_d / bsv_hours_per_year
  end

  def to_s
    self.class.model_name.human
  end

  private

  def assert_group_has_reporting
    unless group.reporting?
      errors.add(:group_id, :is_not_allowed)
    end
  end

  def bsv_hours_per_year
    globals ? globals.bsv_hours_per_year : 1900
  end

  def globals
    @globals ||= ReportingParameter.for(year)
  end

  def update_totals
    @total_paragraph_74 = nil
    calculate_total_lufeb_general
    calculate_total_lufeb_private
    calculate_total_lufeb_specific
    calculate_total_lufeb_promoting
  end

  # rubocop:disable MethodLength
  def calculate_total_lufeb_general
    self.total_lufeb_general =
      kontakte_medien.to_i +
      interviews.to_i +
      publikationen.to_i +
      referate.to_i +
      medienkonferenzen.to_i +
      informationsveranstaltungen.to_i +
      sensibilisierungskampagnen.to_i +
      allgemeine_auskunftserteilung.to_i +
      kontakte_meinungsbildner.to_i +
      beratung_medien.to_i
  end
  # rubocop:enable MethodLength

  def calculate_total_lufeb_private
    self.total_lufeb_private =
      eigene_zeitschriften.to_i +
      newsletter.to_i +
      informationsbroschueren.to_i +
      eigene_webseite.to_i
  end

  def calculate_total_lufeb_specific
    self.total_lufeb_specific =
      erarbeitung_instrumente.to_i +
      erarbeitung_grundlagen.to_i +
      projekte.to_i +
      vernehmlassungen.to_i +
      gremien.to_i
  end

  def calculate_total_lufeb_promoting
    self.total_lufeb_promoting =
      auskunftserteilung.to_i +
      vermittlung_kontakte.to_i +
      unterstuetzung_selbsthilfeorganisationen.to_i +
      koordination_selbsthilfe.to_i +
      treffen_meinungsaustausch.to_i +
      beratung_fachhilfeorganisationen.to_i +
      unterstuetzung_behindertenhilfe.to_i
  end

end
