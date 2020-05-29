# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::VariousAbility
  extend ActiveSupport::Concern

  included do
    on(Event::Kind) do
      permission(:admin).may(:manage).none
    end

    on(ReportingParameter) do
      class_side(:index).if_admin
      permission(:admin).may(:manage).all
    end

    on(GlobalValue) do
      permission(:admin).may(:show, :update).all
    end
  end

end
