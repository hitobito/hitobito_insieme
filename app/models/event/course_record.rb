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
  validates :kurstage, :absenzen_behinderte, :absenzen_angehoerige, :absenzen_weitere,
            modulus:  { multiple: 0.5 }

  def to_s
    ''
  end

  def inputkriterien
    super || 'a'
  end

  def kursart
    super || 'weiterbildung'
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
