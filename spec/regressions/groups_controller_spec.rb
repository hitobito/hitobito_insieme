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
       [:regio_leader, :be, :visible]].each do |person, group, state|

         it "is #{state} to #{person} on #{group}" do
           sign_in(people(person))
           get :show, id: groups(group).id
           if state == :visible
             dom.should have_content 'Reporting'
           else
             dom.should_not have_content 'Reporting'
           end
         end
       end
    end

  end
end
