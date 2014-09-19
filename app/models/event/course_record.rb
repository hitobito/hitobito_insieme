# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class Event::CourseRecord < ActiveRecord::Base

  belongs_to :event, inverse_of: :course_record, class_name: 'Event::Course'

  validate :must_be_a_not_subsidized
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

  def set_defaults
    self[:kursart] ||= 'weiterbildung'
    self[:inputkriterien] ||= 'a'
    self[:subventioniert] ||= true if subventioniert.nil?

    if sk?
      self[:spezielle_unterkunft] = false
      self[:inputkriterien] = 'a'
    end

    true # ensure callback chain continues
  end

  private

  def assert_event_is_course
    if event && event.class != Event::Course
      errors.add(:event, :is_not_allowed)
    end
  end

  def must_be_a_not_subsidized
    if inputkriterien != 'a'
      errors.add(:inputkriterien, :must_be_a_not_subsidized) unless subventioniert
    end
  end

end
