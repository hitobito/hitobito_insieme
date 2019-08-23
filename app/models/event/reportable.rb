# encoding: utf-8

#  Copyright (c) 2012-2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Event::Reportable

  extend ActiveSupport::Concern

  LEISTUNGSKATEGORIEN = %w(bk tk sk tp).freeze
  FACHKONZEPTE = %w(
    freizeit_jugend freizeit_erwachsen
    sport_jugend sport_erwachsen
    autonomie_foerderung
    treffpunkt
  ).freeze

  included do
    self.used_attributes += [:leistungskategorie, :fachkonzept]

    has_one :course_record, foreign_key: :event_id, dependent: :destroy, inverse_of: :event
    accepts_nested_attributes_for :course_record

    attr_readonly :leistungskategorie

    validates :leistungskategorie, inclusion: LEISTUNGSKATEGORIEN
    validates :fachkonzept,        inclusion: FACHKONZEPTE
    validate :fachkonzept_of_leistungskategorie
    validate :assert_year_not_frozen
  end

  ### INSTANCE METHODS

  def years
    dates.
      map { |date| [date.start_at, date.finish_at] }.
      flatten.
      compact.
      map(&:year).
      uniq.
      sort
  end

  def reportable?
    true
  end

  def reporting_frozen?
    frozen = GlobalValue.reporting_frozen_until_year
    frozen && course_record && course_record.year && course_record.year <= frozen
  end

  private

  def assert_year_not_frozen
    if reporting_frozen?
      errors.add(:base, :event_reporting_frozen)
    end
  end

  def fachkonzept_of_leistungskategorie
    if kurs_leistungskategorie? && treffpunkt_fachkonzept?
      errors.add(:fachkonzept, :invalid_for_course_leistungskategorie)
    elsif treffpunkt_leistungskategorie? && kurs_fachkonzept?
      errors.add(:fachkonzept, :invalid_for_treffpunkt_leistungskategorie)
    end
  end

  def kurs_leistungskategorie?
    (LEISTUNGSKATEGORIEN - ['tp']).include? leistungskategorie
  end

  def kurs_fachkonzept?
    (FACHKONZEPTE - ['treffpunkt']).include? fachkonzept
  end

  def treffpunkt_leistungskategorie?
    leistungskategorie == 'tp'
  end

  def treffpunkt_fachkonzept?
    fachkonzept == 'treffpunkt'
  end

  module ClassMethods
    def available_leistungskategorien
      LEISTUNGSKATEGORIEN.map do |period|
        [period, I18n.t("activerecord.attributes.event/course.leistungskategorien.#{period}.one")]
      end
    end

    def available_fachkonzepte
      FACHKONZEPTE.map do |period|
        [period, I18n.t("activerecord.attributes.event/course.fachkonzepte.#{period}")]
      end
    end
  end
end
