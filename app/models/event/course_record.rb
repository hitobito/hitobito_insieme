# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.
#
# == Schema Information
#
# Table name: event_course_records
#
#  id                               :integer          not null, primary key
#  event_id                         :integer          not null
#  inputkriterien                   :string(1)
#  subventioniert                   :boolean          default(TRUE), not null
#  kursart                          :string(255)
#  kursdauer                        :decimal(12, 2)
#  teilnehmende_behinderte          :integer
#  teilnehmende_angehoerige         :integer
#  teilnehmende_weitere             :integer
#  absenzen_behinderte              :decimal(12, 2)
#  absenzen_angehoerige             :decimal(12, 2)
#  absenzen_weitere                 :decimal(12, 2)
#  leiterinnen                      :integer
#  fachpersonen                     :integer
#  hilfspersonal_ohne_honorar       :integer
#  hilfspersonal_mit_honorar        :integer
#  kuechenpersonal                  :integer
#  honorare_inkl_sozialversicherung :decimal(12, 2)
#  unterkunft                       :decimal(12, 2)
#  uebriges                         :decimal(12, 2)
#  beitraege_teilnehmende           :decimal(12, 2)
#  spezielle_unterkunft             :boolean          default(FALSE), not null
#  year                             :integer
#  teilnehmende_mehrfachbehinderte  :integer
#  direkter_aufwand                 :decimal(12, 2)
#  gemeinkostenanteil               :decimal(12, 2)
#  gemeinkosten_updated_at          :datetime
#  zugeteilte_kategorie             :string(2)
#  challenged_canton_count_id       :integer
#  affiliated_canton_count_id       :integer
#  anzahl_kurse                     :integer          default(1)
#  tage_behinderte                  :decimal(12, 2)
#  tage_angehoerige                 :decimal(12, 2)
#  tage_weitere                     :decimal(12, 2)
#

class Event::CourseRecord < ActiveRecord::Base

  INPUTKRITERIEN = %w(a b c)
  KURSARTEN = %w(weiterbildung freizeit_und_sport)

  belongs_to :event
  belongs_to :challenged_canton_count, dependent: :destroy,
                                       class_name: 'Event::ParticipationCantonCount'
  belongs_to :affiliated_canton_count, dependent: :destroy,
                                       class_name: 'Event::ParticipationCantonCount'

  accepts_nested_attributes_for :challenged_canton_count
  accepts_nested_attributes_for :affiliated_canton_count

  validates_by_schema
  validates :event_id, uniqueness: true
  validates :inputkriterien, inclusion: { in: INPUTKRITERIEN }
  validates :kursart, inclusion: { in: KURSARTEN }
  validates :year, inclusion: { in: ->(course_record) { course_record.event.years } }
  validates :anzahl_kurse, numericality: { greater_than: 0 }
  validates :kursdauer,
            :teilnehmende_behinderte,
            :teilnehmende_angehoerige,
            :teilnehmende_weitere,
            :absenzen_behinderte,
            :absenzen_angehoerige,
            :absenzen_weitere,
            :tage_behinderte,
            :tage_angehoerige,
            :tage_weitere,
            :leiterinnen,
            :fachpersonen,
            :hilfspersonal_ohne_honorar,
            :hilfspersonal_mit_honorar,
            :kuechenpersonal,
            :teilnehmende_mehrfachbehinderte,
            numericality: { greater_than_or_equal_to: 0, allow_blank: true }

  validate :assert_mehrfachbehinderte_less_than_behinderte
  validate :assert_duration_values_precision


  before_validation :set_defaults
  before_validation :set_cached_values
  before_validation :compute_category

  attr_writer :anzahl_spezielle_unterkunft

  Event::Course::LEISTUNGSKATEGORIEN.each do |kategorie|
    define_method(:"#{kategorie}?") do
      event.leistungskategorie == kategorie
    end
  end

  def to_s
    ''
  end

  def year
    super || event.years.first
  end

  def total_absenzen
    absenzen_behinderte.to_d +
    absenzen_angehoerige.to_d +
    absenzen_weitere.to_d
  end

  def teilnehmende
    teilnehmende_behinderte.to_i +
    teilnehmende_angehoerige.to_i +
    teilnehmende_weitere.to_i
  end

  def betreuende
    leiterinnen.to_i +
    fachpersonen.to_i +
    hilfspersonal_mit_honorar.to_i +
    hilfspersonal_ohne_honorar.to_i
  end

  def total_tage_teilnehmende
    tage_behinderte.to_d +
    tage_angehoerige.to_d +
    tage_weitere.to_d
  end

  def praesenz_prozent
    if total_tage_teilnehmende > 0
      100 - ((total_absenzen / total_tage_teilnehmende) * 100).round
    else
      100
    end
  end

  def betreuungsschluessel
    if betreuende.to_d > 0
      teilnehmende_behinderte.to_d / betreuende.to_d
    else
      0
    end
  end

  def total_vollkosten
    direkter_aufwand.to_d +
    gemeinkostenanteil.to_d
  end

  def direkte_kosten_pro_le
    if total_tage_teilnehmende > 0
      direkter_aufwand.to_d / total_tage_teilnehmende
    else
      0
    end
  end

  def vollkosten_pro_le
    if total_tage_teilnehmende > 0
      total_vollkosten / total_tage_teilnehmende
    else
      0
    end
  end

  def anzahl_spezielle_unterkunft
    @anzahl_spezielle_unterkunft ||
      attributes['anzahl_spezielle_unterkunft'] ||
      (spezielle_unterkunft ? 1 : 0)
  end

  # rubocop:disable MethodLength
  def set_defaults
    self.kursart ||= 'weiterbildung'
    self.inputkriterien ||= 'a'
    self.subventioniert ||= true if subventioniert.nil?
    self.year = event.years.first if event.years.size == 1
    self.anzahl_kurse = 1 if event.is_a?(Event::Course)

    if sk?
      self.spezielle_unterkunft = false
      self.inputkriterien = 'a'
    end

    true # ensure callback chain continues
  end
  # rubocop:enable MethodLength

  private

  def compute_category
    assigner = CourseReporting::CategoryAssigner.new(self)
    begin
      self.zugeteilte_kategorie = assigner.compute
    rescue NotImplementedError
      self.zugeteilte_kategorie = nil
    end
  end

  def set_cached_values
    self.teilnehmende_behinderte = challenged_canton_count && challenged_canton_count.total
    self.teilnehmende_angehoerige = affiliated_canton_count && affiliated_canton_count.total
    self.direkter_aufwand = calculate_direkter_aufwand
    unless event.is_a?(Event::AggregateCourse)
      self.tage_behinderte = calculate_tage_behinderte
      self.tage_angehoerige = calculate_tage_angehoerige
      self.tage_weitere = calculate_tage_weitere
    end
  end

  def calculate_tage_behinderte
    (kursdauer.to_d * teilnehmende_behinderte.to_i) - absenzen_behinderte.to_d
  end

  def calculate_tage_angehoerige
    (kursdauer.to_d * teilnehmende_angehoerige.to_i) - absenzen_angehoerige.to_d
  end

  def calculate_tage_weitere
    (kursdauer.to_d * teilnehmende_weitere.to_i) - absenzen_weitere.to_d
  end

  def calculate_direkter_aufwand
    honorare_inkl_sozialversicherung.to_d +
    unterkunft.to_d +
    uebriges.to_d
  end

  def assert_event_is_course
    if event && !event.reportable?
      errors.add(:event, :is_not_allowed)
    end
  end

  def assert_mehrfachbehinderte_less_than_behinderte
    if teilnehmende_mehrfachbehinderte.to_i > teilnehmende_behinderte.to_i
      errors.add(:teilnehmende_mehrfachbehinderte, :less_than_teilnehmende_behinderte)
    end
  end

  def assert_duration_values_precision
    duration_attrs.each do |attr|
      value = send(attr)
      next unless value

      if sk?
        check_modulus(attr, value, 1, :not_an_integer)
      else
        msg = I18n.t('activerecord.errors.messages.must_be_multiple_of', multiple: 0.5)
        check_modulus(attr, value, 0.5, msg)
      end
    end
  end

  def duration_attrs
    attrs = [:kursdauer, :absenzen_behinderte, :absenzen_angehoerige, :absenzen_weitere]
    if event.is_a?(Event::AggregateCourse)
      attrs += [:tage_behinderte, :tage_angehoerige, :tage_weitere]
    end
    attrs
  end

  def check_modulus(attr, value, multiple, message)
    if value % multiple != 0
      errors.add(attr, message)
    end
  end

end
