# frozen_string_literal: true

#  Copyright (c) 2020, Insieme Schweiz. This file is part of hitobito_insieme
#  and licensed under the Affero General Public License version 3 or later. See
#  the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module VertragsperiodenHelper
  def vp_i18n_scope
    Vertragsperioden::Dispatcher.new(year).i18n_scope(controller_name)
  end

  def vp_t(key, options = {})
    scope = [vp_i18n_scope]
    scope << action_name if key.to_s.start_with?('.')

    translate(
      key.delete_prefix('.'),
      { scope: scope.join('.') }.merge(options)
    )
  end
end
