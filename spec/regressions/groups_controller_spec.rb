# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'
describe GroupsController, type: :controller  do
  include CrudControllerTestHelper
  render_views

  let(:asterix)  { groups(:asterix) }
  let(:flock) { groups(:bern) }
  let(:agency) { groups(:be_agency) }
  let(:region) { groups(:city) }
  let(:state) { groups(:be) }


  let(:dom) { Capybara::Node::Simple.new(response.body) }

  describe_action :get, :show, id: true do

    context 'reporting tab' do
      [[:top_leader, :dachverein, :visible],
       [:top_leader, :be, :visible],
       [:regio_leader, :dachverein, :not_visible],
       [:regio_leader, :fr, :not_visible],
       [:regio_leader, :be, :visible],
       [:regio_aktiv, :be, :not_visible]].each do |person, group, state|

         it "is #{state} to #{person} on #{group}" do
           assert_tab_visibility(person, group, 'Reporting', state)
         end
       end
    end

    context 'course tab' do
      [[:top_leader, :dachverein, :visible],
       [:top_leader, :be, :visible],
       [:regio_leader, :dachverein, :not_visible],
       [:regio_leader, :fr, :visible],
       [:regio_leader, :be, :visible],
       [:regio_aktiv, :dachverein, :not_visible],
       [:regio_aktiv, :be, :visible],
       [:regio_aktiv, :fr, :visible]].each do |person, group, state|

         it "is #{state} to #{person} on #{group}" do
           assert_tab_visibility(person, group, 'Kurse', state)
         end
       end
    end

    context 'aggregate course tab' do
      [[:top_leader, :dachverein, :visible],
       [:top_leader, :be, :visible],
       [:regio_leader, :dachverein, :not_visible],
       [:regio_leader, :fr, :not_visible],
       [:regio_leader, :be, :visible],
       [:regio_aktiv, :dachverein, :not_visible],
       [:regio_aktiv, :be, :not_visible],
       [:regio_aktiv, :fr, :not_visible]].each do |person, group, state|

         it "is #{state} to #{person} on #{group}" do
           assert_tab_visibility(person, group, 'Sammelkurse', state)
         end
       end
    end

    def assert_tab_visibility(person, group, tab, state)
       sign_in(people(person))
       get :show, params: { id: groups(group).id }
       if state == :visible
         expect(dom.find('.sheet .nav')).to have_content tab
       else
         expect(dom.find('.sheet .nav')).not_to have_content tab
       end
    end
  end
end
