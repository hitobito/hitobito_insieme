# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# == Schema Information
#
# Table name: event_course_records
#
#  id                               :integer          not null, primary key
#  event_id                         :integer          not null
#  inputkriterien                   :string(1)
#  subventioniert                   :boolean
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
#  spezielle_unterkunft             :boolean
#  year                             :integer
#  teilnehmende_mehrfachbehinderte  :integer
#  total_direkte_kosten             :decimal(12, 2)
#  gemeinkostenanteil               :decimal(12, 2)
#  gemeinkosten_updated_at          :datetime
#  zugeteilte_kategorie             :string(2)
#

class Event::CourseRecord < ActiveRecord::Base

  INPUTKRITERIEN = %w(a b c)
  KURSARTEN = %w(weiterbildung freizeit_und_sport)

  belongs_to :event, inverse_of: :course_record, class_name: 'Event::Course'

  validates :inputkriterien, inclusion: { in: INPUTKRITERIEN }
  validates :kursart, inclusion: { in: KURSARTEN }
  validates :year, inclusion: { in: ->(course_record) { course_record.event.years } }
  validates :kursdauer, :absenzen_behinderte, :absenzen_angehoerige, :absenzen_weitere,
            modulus:  { multiple: 0.5, if: -> { !sk? } },
            numericality: { only_integer: true, allow_nil: true, if: :sk? }
  validate :assert_mehrfachbehinderte_less_than_behinderte

  before_validation :set_defaults
  before_validation :compute_category

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

  def tage_behinderte
    @tage_behinderte ||=
      (kursdauer.to_d * teilnehmende_behinderte.to_i) - absenzen_behinderte.to_d
  end

  def tage_angehoerige
    @tage_angehoerige ||=
      (kursdauer.to_d * teilnehmende_angehoerige.to_i) - absenzen_angehoerige.to_d
  end

  def tage_weitere
    @tage_weitere ||=
      (kursdauer.to_d * teilnehmende_weitere.to_i) - absenzen_weitere.to_d
  end

  def total_tage_teilnehmende
    tage_behinderte +
    tage_angehoerige +
    tage_weitere
  end

  def praesenz_prozent
    if kursdauer.to_d > 0 && teilnehmende > 0
      100 - ((total_absenzen / (kursdauer.to_d * teilnehmende)) * 100).round
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

  def direkter_aufwand
    honorare_inkl_sozialversicherung.to_d +
    unterkunft.to_d +
    uebriges.to_d
  end

  def total_vollkosten
    direkter_aufwand +
    gemeinkostenanteil.to_d
  end

  def vollkosten_pro_le
    @vollkosten_pro_le ||=
      if total_tage_teilnehmende > 0
        total_vollkosten / total_tage_teilnehmende
      else
        0
      end
  end

  def set_defaults
    self.kursart ||= 'weiterbildung'
    self.inputkriterien ||= 'a'
    self.subventioniert ||= true if subventioniert.nil?
    self.total_direkte_kosten = direkter_aufwand
    self.year = event.years.first if event.years.size == 1

    if sk?
      self.spezielle_unterkunft = false
      self.inputkriterien = 'a'
    end

    true # ensure callback chain continues
  end

  def compute_category
    assigner = CourseReporting::CategoryAssigner.new(self)
    self.zugeteilte_kategorie = assigner.compute
  end

  private

  def assert_event_is_course
    if event && event.class != Event::Course
      errors.add(:event, :is_not_allowed)
    end
  end

  def assert_mehrfachbehinderte_less_than_behinderte
    if teilnehmende_mehrfachbehinderte.to_i > teilnehmende_behinderte.to_i
      errors.add(:teilnehmende_mehrfachbehinderte, :less_than_teilnehmende_behinderte)
    end
  end

end
