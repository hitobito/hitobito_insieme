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
#
class Event::CourseRecord < ActiveRecord::Base

  belongs_to :event, inverse_of: :course_record, class_name: 'Event::Course'

  validates :inputkriterien, inclusion: { in: %w(a b c) }
  validates :kursart, inclusion: { in: %w(weiterbildung freizeit_und_sport) }
  validates :kursdauer, :absenzen_behinderte, :absenzen_angehoerige, :absenzen_weitere,
            modulus:  { multiple: 0.5, if: -> { !sk? } },
            numericality: { only_integer: true, allow_nil: true, if: :sk? }

  before_validation :set_defaults

  Event::Course::LEISTUNGSKATEGORIEN.each do |kategorie|
    define_method(:"#{kategorie}?") do
      event.leistungskategorie == kategorie
    end
  end

  def to_s
    ''
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

  def set_defaults
    self.kursart ||= 'weiterbildung'
    self.inputkriterien ||= 'a'
    self.subventioniert ||= true if subventioniert.nil?

    if sk?
      self.spezielle_unterkunft = false
      self.inputkriterien = 'a'
    end

    true # ensure callback chain continues
  end

  private

  def assert_event_is_course
    if event && event.class != Event::Course
      errors.add(:event, :is_not_allowed)
    end
  end

end
