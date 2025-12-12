# frozen_string_literal: true

#  Copyright (c) 2012-2025, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class ClearAhvData < ActiveRecord::Migration[8.0]
  REGEXP = "\nahv_number:\n-.*?\n-.*\n"
  NEWLINE = "E'\n'"

  def up
    remove_column(:people, :ahv_number)
    remove_ahv_changes_from_versions
    delete_empty_versions
  end

  def remove_ahv_changes_from_versions
    PaperTrail::Version.where("object_changes ~ '#{REGEXP}'")
      .update_all(object_changes: Arel.sql("REGEXP_REPLACE(object_changes, '#{REGEXP}', #{NEWLINE},'g')"))
  end

  def delete_empty_versions
    PaperTrail::Version.where(object_changes: "---\n").delete_all
  end
end
