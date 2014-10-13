# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module RenderPeopleExports

    extend ActiveSupport::Concern

    included do
      alias_method_chain :generate_pdf, :address_type
    end

    def generate_pdf_with_address_type(people)
      ::Export::Pdf::Labels.new(find_and_remember_label_format, params[:address_type]).
                            generate(people)
    end
  end
end
