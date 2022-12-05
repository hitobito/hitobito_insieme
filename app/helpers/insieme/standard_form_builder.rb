# frozen_string_literal: true

#  Copyright (c) 2020, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module StandardFormBuilder
    extend ActiveSupport::Concern

    included do
      delegate :fp_i18n_scope, to: :template
    end

    def labeled_fp_input_field(field, options)
      options = options.merge(label: I18n.t(field,
                                            scope: fp_i18n_scope,
                                            default: labeled(field)))

      labeled_input_field field, options
    end
  end
end
