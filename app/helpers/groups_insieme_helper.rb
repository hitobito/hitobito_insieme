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
    candidates_from_i18n(:cantons)
  end

  private

  def candidates_from_i18n(collection_attr)
    t("activerecord.attributes.group.#{collection_attr}").map do |key, value|
      Struct.new(:id, :to_s).new(key, value)
    end
  end
end
