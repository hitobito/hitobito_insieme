# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Event::CourseRecordsController, type: :controller do

  render_views

  let(:group) { groups(:dachverein) }
  let(:event_bk) do
    Fabricate(:course, groups: [group], kind: Event::Kind.first,
              leistungskategorie: 'bk')
  end
  let(:event_tk) do
    Fabricate(:course, groups: [group], kind: Event::Kind.first,
              leistungskategorie: 'tk')
  end
  let(:event_sk) do
    Fabricate(:course, groups: [group], kind: Event::Kind.first,
              leistungskategorie: 'sk')
  end

  let(:dom) { Capybara::Node::Simple.new(response.body) }

  before { sign_in(people(:top_leader)) }

  context 'inputkriterien and spezielle_unterkunft' do
    it 'should display inputkriterien/spezielle_unterkunft for bk course' do
      get :edit, group_id: group.id, event_id: event_bk.id
      dom.should have_content 'Inputkriterien'
      dom.should have_content 'Spezielle Unterkunft'
    end

    it 'should display inputkriterien/spezielle_unterkunft for tk course' do
      get :edit, group_id: group.id, event_id: event_tk.id
      dom.should have_content 'Inputkriterien'
      dom.should have_content 'Spezielle Unterkunft'
    end

    it 'should display inputkriterien/spezielle_unterkunft for sk course' do
      get :edit, group_id: group.id, event_id: event_sk.id
      dom.should_not have_content 'Inputkriterien'
      dom.should_not have_content 'Spezielle Unterkunft'
    end
  end

end
