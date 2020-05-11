# frozen_string_literal: true

#  Copyright (c) 2020, Insieme Schweiz. This file is part of hitobito_insieme
#  and licensed under the Affero General Public License version 3 or later. See
#  the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

RSpec.shared_context 'vertragsperioden' do
  include Vertragsperioden::Domain
end

RSpec.configure do |rspec|
  rspec.include_context 'vertragsperioden'
end
