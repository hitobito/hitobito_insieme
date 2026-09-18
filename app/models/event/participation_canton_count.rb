# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# == Schema Information
#
# Table name: event_participation_canton_counts
#
#  id    :integer          not null, primary key
#  ag    :integer
#  ai    :integer
#  ar    :integer
#  be    :integer
#  bl    :integer
#  bs    :integer
#  fr    :integer
#  ge    :integer
#  gl    :integer
#  gr    :integer
#  ju    :integer
#  lu    :integer
#  ne    :integer
#  nw    :integer
#  ow    :integer
#  sg    :integer
#  sh    :integer
#  so    :integer
#  sz    :integer
#  tg    :integer
#  ti    :integer
#  ur    :integer
#  vd    :integer
#  vs    :integer
#  zg    :integer
#  zh    :integer
#  another :integer
#

class Event::ParticipationCantonCount < ActiveRecord::Base
  # The count columns of this table: one per canton plus "another" for
  # participants without a Swiss canton. "another" is a reporting
  # category, not a valid Person#canton value. Static list (not
  # column_names) so loading this class does not query the database,
  # e.g. when compiling assets before migrations ran.
  CANTON_ATTRIBUTES = Cantons.short_name_strings + %w[another]

  has_one :course_record_as_challenged_canton_count, foreign_key: :challenged_canton_count_id,
    inverse_of: :challenged_canton_count,
    dependent: :nullify,
    class_name: "Event::CourseRecord"
  has_one :course_record_as_affiliated_canton_count, foreign_key: :affiliated_canton_count_id,
    inverse_of: :affiliated_canton_count,
    dependent: :nullify,
    class_name: "Event::CourseRecord"

  validates_by_schema
  validates(*CANTON_ATTRIBUTES,
    numericality: {greater_than_or_equal_to: 0, allow_blank: true})

  def total
    CANTON_ATTRIBUTES.sum { |c| attributes[c].to_i }
  end
end
