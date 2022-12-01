# frozen_string_literal: true

#  Copyright (c) 2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Featureperioden
  module Views
    extend ActiveSupport::Concern

    included do
      before_action :featureperioden_viewpath
    end

    private

    def featureperioden_viewpath
      raise Featureperioden::NoYearError if year.blank?

      prepend_view_path(Featureperioden::Dispatcher.new(year).view_path)
    end
  end
end
