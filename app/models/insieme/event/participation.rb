#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module Event
    module Participation
      extend ActiveSupport::Concern

      include I18nEnums

      DISABILITIES = %w(geistig hoer koerper krankheit psychisch seh sprach sucht)

      included do
        accepts_nested_attributes_for :person

        i18n_enum :disability, DISABILITIES
      end

    end
  end
end
