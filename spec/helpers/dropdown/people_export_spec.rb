# encoding: utf-8

#  Copyright (c) 2014, Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe 'Insieme::Dropdown::PeopleExport' do

  include FormatHelper
  include LayoutHelper

  let(:user) { people(:top_leader) }
  let(:dropdown) do
    Dropdown::PeopleExport.new(self,
                               user,
                               { controller: 'people', group_id: groups(:dachverein).id },
                               false,
                               false)
  end

  subject { dropdown.to_s }

  def can?(*args)
    true
  end

  it 'renders dropdown' do
    should have_content 'Export'
    should have_selector 'ul.dropdown-menu'
    should have_selector 'a' do |tag|
      tag.should have_content 'CSV'
      tag.should_not have_selector 'ul.dropdown-submenu'
    end
    should have_selector 'a' do |tag|
      tag.should have_content 'Etiketten'
      tag.should have_selector 'ul.dropdown-submenu' do |pdf|
        pdf.should have_content 'Standard'
        pdf.should have_selectur 'ul.dropdown-submenu' do |type|
          pdf.should have_content 'Hauptadresse'
        end
      end
    end
    should have_selector 'a' do |tag|
      tag.should_not have_content 'E-Mail Adressen'
    end
  end
end
