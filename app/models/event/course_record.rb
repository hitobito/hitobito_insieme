# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class Event::CourseRecord < ActiveRecord::Base

  belongs_to :event

  validate :assert_event_is_course, on: :create
  validate :check_inputkriterien_a
  validates :inputkriterien, inclusion: { in: %w(a b c) }
  validates :kursart, inclusion: { in: %w(weiterbildung freizeit_und_sport) }
  validates :kursdauer, :absenzen_behinderte, :absenzen_angehoerige, :absenzen_weitere,
            modulus:  { multiple: 0.5, if: -> { !sk? } },
            numericality: { only_integer: true, allow_nil: true, if: :sk? }

  before_validation :set_defaults

  Event::Course::LEISTUNGSKATEGORIEN.each do |kategorie|
    define_method(:"#{kategorie}?") do
      event.leistungskategorie && event.leistungskategorie == kategorie
    end
  end

  def to_s
    ''
  end

  def set_defaults
    self[:inputkriterien] ||= 'a'
    self[:kursart] ||= 'weiterbildung'
    self[:subventioniert] ||= true if subventioniert.nil?
    self[:spezielle_unterkunft] = false if event.leistungskategorie == 'sk'

    true # ensure callback chain continues
  end

  private

  def assert_event_is_course
    if event && event.class != Event::Course
      errors.add(:event, :is_not_allowed)
    end
  end

  def check_inputkriterien_a
    if inputkriterien != 'a'
      unless subventioniert
        errors.add(:inputkriterien, :must_be_a_not_subsidized)
      end
      if event.leistungskategorie == 'sk'
        errors.add(:inputkriterien, :must_be_a_sk)
      end
    end
  end


end
