#  Copyright (c) 2014-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module RenderPeopleExports
    def generate_pdf(people, group)
      if params[:label_format_id]
        ::Export::Pdf::Labels.new(find_and_remember_label_format, params[:address_type]).
          generate(people)
      else
        ::Export::Pdf::List.render(people, group)
      end
    end
  end
end
