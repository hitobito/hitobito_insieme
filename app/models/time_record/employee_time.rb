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

class TimeRecord::EmployeeTime < TimeRecord

  has_one :employee_pensum, foreign_key: :time_record_id, dependent: :destroy,
          inverse_of: :time_record
  accepts_nested_attributes_for :employee_pensum

  before_save :update_lufeb_subtotals

  private

  def update_lufeb_subtotals
    calculate_total_lufeb_general!
    calculate_total_lufeb_private!
    calculate_total_lufeb_specific!
    calculate_total_lufeb_promoting!
  end

end
