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
            modulus:  { multiple: 0.5, if: :not_sk? },
            numericality: { only_integer: true, allow_nil: true, if: :sk? }

  def to_s
    ''
  end

  def subventioniert
    super.nil? && true || super
  end

  def inputkriterien
    super || 'a'
  end

  def kursart
    super || 'weiterbildung'
  end

  def spezielle_unterkunft
    event.leistungskategorie != 'sk' && super || false
  end

  def bk?
    event.leistungskategorie == 'bk'
  end

  def tk?
    event.leistungskategorie == 'tk'
  end

  def sk?
    event.leistungskategorie == 'sk'
  end

  def not_sk?
    event.leistungskategorie != 'sk'
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
