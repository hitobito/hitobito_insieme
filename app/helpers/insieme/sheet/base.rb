# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Sheet::Base
  extend ActiveSupport::Concern

  included do
    class << self
      alias_method_chain :current_sheet_class, :reports
    end
  end

  module ClassMethods
    private

    def current_sheet_class_with_reports(view_context)
      case view_context.controller
      when ReportingBaseController
        Sheet::Group
      when Event::CourseRecordsController
        Sheet::Event
      else
        current_sheet_class_without_reports(view_context)
      end
    end
  end
end
