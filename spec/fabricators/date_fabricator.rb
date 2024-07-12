#  Copyright (c) 2012-2022, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/insieme_insieme.

Fabricator(:fp2015_date, from: :event_date) do
  start_at { Date.new(2015, 6, 1) }
  finish_at { |date| date[:start_at] + 7.days }
end

Fabricator(:fp2020_date, from: :event_date) do
  start_at { Date.new(2020, 6, 1) }
  finish_at { |date| date[:start_at] + 7.days }
end

Fabricator(:fp2022_date, from: :event_date) do
  start_at { Date.new(2022, 12, 1) }
  finish_at { |date| date[:start_at] + 7.days }
end
