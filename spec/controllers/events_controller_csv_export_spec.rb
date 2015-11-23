# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe EventsController do


  context 'GET#index as CSV' do

    context 'dachverein' do
      before do
        sign_in(people(:top_leader))
        c = Fabricate(:course, groups: [groups(:dachverein)], kind: Event::Kind.first,
                                            leistungskategorie: 'bk')
        Fabricate(:event_date, event: c, start_at: Date.new(2012, 3, 5))
      end 
      let(:group) { groups(:dachverein) }

      it 'creates default export for events' do
        get :index, group_id: group.id, event: { type: 'Event' }, format: 'csv'

        expect_default_export
      end

      it 'creates detail export for courses' do
        get :index, group_id: group.id, type: 'Event::Course', format: 'csv', year: '2012'

        expect_detail_export
      end

      it 'creates default export for courses if requested by Präsident' do
        get :index, group_id: group.id, event: { type: 'Event::Course' }, format: 'csv'
        praesident = Fabricate(Group::Dachverein::Praesident.name.to_sym, group: group).person
        sign_in(praesident)

        expect_default_export
      end
    end

    context 'regionalverein' do
      before do
        sign_in(people(:regio_leader))
        c = Fabricate(:course, groups: [groups(:be)], kind: Event::Kind.first,
                                            leistungskategorie: 'bk')
        Fabricate(:event_date, event: c, start_at: Date.new(2012, 3, 5))
      end
      let(:group) { groups(:be) }

      it 'creates detail export for courses' do
        get :index, group_id: group.id, type: 'Event::Course', format: 'csv', year: '2012'

        expect_detail_export
      end

      it 'denies export to controlling if not controlling in group' do
        controlling = Fabricate(Group::Regionalverein::Controlling.name.to_sym, group: groups(:fr)).person
        expect do
          sign_in(controlling)
          get :index, group_id: group.id, type: 'Event::Course', format: 'csv', year: '2012'
        end.to raise_error(CanCan::AccessDenied)
      end
    end

  end

private
  def expect_default_export
    headers = response.body.lines.first.split(';')
    expect(headers.count).to eq(44)
    expect(headers).not_to include 'Behinderte'
    expect(headers).not_to include "Weitere, nicht Beitragsberechtigt\n"
  end

  def expect_detail_export
    headers = response.body.lines.first.split(';')
    expect(headers.count).to eq(63)
    expect(headers).to include 'Behinderte'
    expect(headers).to include "Weitere, nicht Beitragsberechtigt\n"
  end

end
