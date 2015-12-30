# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Person::QueryController do

  let(:person) { people(:top_leader) }

  context 'GET query' do
    before { sign_in(person) }

    it 'searches number as well' do
      people(:top_leader).update!(number: 107)
      people(:regio_aktiv).update!(number: 10107)
      people(:regio_leader).update!(number: 10007)
      get :index, q: '107', format: :json

      expect(@response.body).to match(/107 Top Leader/)
      expect(@response.body).to match(/10107 Active Person/)
      expect(@response.body).not_to match(/Flock Leader/)
    end
  end

end
