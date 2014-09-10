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
#

class TimeRecord < ActiveRecord::Base

  belongs_to :group


  validates :year, uniqueness: { scope: [:group_id] }
  validate :assert_group_has_reporting

  # rubocop:disable MethodLength
  def lufeb
    @lufeb ||= begin
      kontakte_medien.to_i +
      interviews.to_i +
      publikationen.to_i +
      referate.to_i +
      medienkonferenzen.to_i +
      informationsveranstaltungen.to_i +
      sensibilisierungskampagnen.to_i +
      allgemeine_auskunftserteilung.to_i +
      kontakte_meinungsbildner.to_i +
      beratung_medien.to_i +

      eigene_zeitschriften.to_i +
      newsletter.to_i +
      informationsbroschueren.to_i +
      eigene_webseite.to_i +

      erarbeitung_instrumente.to_i +
      erarbeitung_grundlagen.to_i +
      projekte.to_i +
      vernehmlassungen.to_i +
      gremien.to_i +

      auskunftserteilung.to_i +
      vermittlung_kontakte.to_i +
      unterstuetzung_selbsthilfeorganisationen.to_i +
      koordination_selbsthilfe.to_i +
      treffen_meinungsaustausch.to_i +
      beratung_fachhilfeorganisationen.to_i +
      unterstuetzung_behindertenhilfe.to_i
    end
  end
  # rubocop:enable MethodLength

  def total
    @total ||= (self.class.column_names - %w(id group_id year)).
                 collect { |c| send(c).to_i }.
                 sum
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
end
