# frozen_string_literal: true

#  Copyright (c) 2020, Insieme Schweiz. This file is part of hitobito_insieme
#  and licensed under the Affero General Public License version 3 or later. See
#  the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module VertragsperiodenHelper
  def vp_labeled_input_fields_with_hours(form, *field_list)
    field_list.map do |field|
      form.labeled_input_field(
        field,
        label: t(field, scope: vp_i18n_scope),
        addon: t('global.hours_short')
      )
    end.join.html_safe
  end

  def vp_i18n_scope
    @vp ||= Vertragsperioden::Dispatcher.new(year)
    @vp.i18n_scope(controller_name)
  end
end
