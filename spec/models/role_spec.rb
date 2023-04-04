# frozen_string_literal: true

#  Copyright (c) 2012-2022, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Role do
    Role.subclasses.each do |role|
      if role.permissions.present?
        it "#{role.name} has permissions so must have two_factor_authentication_enforced=true" do
          expect(role).to be_two_factor_authentication_enforced
        end
      end

    end
end
