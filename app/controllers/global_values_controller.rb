# encoding: utf-8

#  Copyright (c) 2012-2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class GlobalValuesController < SimpleCrudController

  self.permitted_attrs = [:default_reporting_year]

  def show
    redirect_to edit_global_value_path
  end

  private

  def index_path
    edit_global_value_path
  end

  def full_entry_label
    entry.to_s
  end

  def entry
    @global_value ||= GlobalValue.first
  end

end
