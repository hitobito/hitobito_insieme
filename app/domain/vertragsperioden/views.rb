# frozen_string_literal: true

#  Copyright (c) 2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vertragsperioden
  module Views
    extend ActiveSupport::Concern

    included do
      before_action :vertragsperioden_viewpath
    end

    private

    def vertragsperioden_viewpath
      raise Vertragsperioden::NoYearError unless year.present?

      prepend_view_path(Vertragsperioden::Dispatch.new(year).view_path)
    end
  end
end
