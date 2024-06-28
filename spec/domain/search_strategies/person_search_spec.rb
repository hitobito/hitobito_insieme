#  Copyright (c) 2012-2024, Hitobito AG. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe SearchStrategies::PersonSearch do

  before do
    people(:regio_leader).update!(number: 12345, salutation: "Wassup Regio Leader")
  end

  describe '#search_fulltext' do
    let(:user) { people(:top_leader) }

    it 'finds accessible person by number' do
      result = search_class(people(:regio_leader).number.to_s).search_fulltext

      expect(result).to include(people(:regio_leader))
    end

    it 'finds accessible person by salutation' do
      result = search_class(people(:regio_leader).salutation[0..5]).search_fulltext

      expect(result).to include(people(:regio_leader))
    end
  end

  def search_class(term = nil, page = nil)
    described_class.new(user, term, page)
  end
end