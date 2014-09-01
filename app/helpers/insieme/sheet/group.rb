# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Sheet::Group
  extend ActiveSupport::Concern

  included do
    tabs.insert(-2,
                Sheet::Tab.new('reporting.title',
                               :cost_accounting_group_path,
                               if: lambda do |view, group|
                                 [Group::Dachverein, Group::Regionalverein].any? do |c|
                                   group.is_a?(c) && view.can?(:reporting, group)
                                 end
                               end))
  end

end
