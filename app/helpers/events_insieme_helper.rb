# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module EventsInsiemeHelper
  def format_leistungskategorie(entry)
    if entry.leistungskategorie?
      I18n.t("activerecord.attributes.event/course.leistungskategorien." \
             "#{entry.leistungskategorie}.one")
    end
  end

  def format_fachkonzept(entry)
    if entry.fachkonzept?
      I18n.t("activerecord.attributes.event/course.fachkonzepte.#{entry.fachkonzept}")
    end
  end
end
