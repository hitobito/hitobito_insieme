# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module GroupsInsiemeHelper

  def format_group_canton(group)
    group.canton_value
  end

  def possible_group_cantons
    (Cantons.short_names - [:other]).map do |c|
      Struct.new(:id, :to_s).new(c, Cantons.full_name(c))
    end
  end

end
