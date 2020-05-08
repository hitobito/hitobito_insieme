# encoding: utf-8

#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Sheet::Base
  extend ActiveSupport::Concern

  class_methods do
    private

    def current_sheet_class(view_context)
      case view_context.controller
      when ReportingBaseController
        Sheet::Group
      when Event::CourseRecordsController
        Sheet::Event
      else
        super(view_context)
      end
    end
  end
end
