# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module GroupsInsiemeHelper

  def format_group_canton(group)
    group.canton_label
  end

  def xlsx_export_events_button
    type = params[:type].presence || 'Event'
    return export_events_button if type == 'Event' # CSV export for events
    if can?(:"export_#{type.underscore.pluralize}", @group)
      action_button(I18n.t('event.lists.courses.xlsx_export_button'),
                    params.merge(format: :xlsx), :download)
    end
  end

end
