# encoding: utf-8

#  Copyright (c) 2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe CourseReporting::AggregationsController do
  let(:group) { groups(:dachverein) }

  before {  sign_in(people(:top_leader)) }
  render_views

  it 'index page renders ok' do
    get :index, id: group.id, year: 2014
    expect(response).to be_ok
  end

  it 'exprt renders ok' do
    get :export, id: group.id, year: 2014, lk: 'bk', subsidized: true, categories: [1,2,3]
    expect(response).to be_ok
  end

end
