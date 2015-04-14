# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe SubscriptionsController do
  let(:group) { groups(:dachverein) }
  let(:person) { people(:top_leader) }

  let!(:list) { Fabricate(:mailing_list, group: group) }
  let!(:subscription) { Fabricate(:subscription, mailing_list: list) }


  before { sign_in(person) }

  render_views

  it 'exports salutation, number, correspondence_language, language, canton and additional_information' do
    get :index,  group_id: group.id, mailing_list_id: list.id, format: :csv

    expect(response.body).to match(/.*Anrede;Korrespondenzsprache;Person Sprache;Kanton;Zusätzliche Angaben;.*/)
  end
end

