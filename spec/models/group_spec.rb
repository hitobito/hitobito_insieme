# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# == Schema Information
#
# Table name: groups
#
#  id             :integer          not null, primary key
#  parent_id      :integer
#  lft            :integer
#  rgt            :integer
#  name           :string(255)      not null
#  short_name     :string(31)
#  type           :string(255)      not null
#  email          :string(255)
#  address        :string(1024)
#  zip_code       :integer
#  town           :string(255)
#  country        :string(255)
#  contact_id     :integer
#  created_at     :datetime
#  updated_at     :datetime
#  deleted_at     :datetime
#  layer_group_id :integer
#  creator_id     :integer
#  updater_id     :integer
#  deleter_id     :integer
#

require 'spec_helper'

describe Group do

  include_examples 'group types'

  describe '#all_types' do
    subject { Group.all_types }

    it 'is in hierarchical order' do
      expect(subject.collect(&:name)).to eq(
        [Group::Dachverein,
         Group::DachvereinListe,
         Group::DachvereinGremium,
         Group::DachvereinAbonnemente,
         Group::Regionalverein,
         Group::RegionalvereinListe,
         Group::RegionalvereinGremium,
         Group::ExterneOrganisation,
         Group::Aktivmitglieder,
         Group::Passivmitglieder,
         Group::Kollektivmitglieder,
         Group::ExterneOrganisationListe,
         Group::ExterneOrganisationGremium
         ].collect(&:name))
    end
  end

  context 'canton_value' do

    it 'is blank for nil value' do
      Group.new.canton_value.should be_blank
    end

    it 'is blank for blank value' do
      Group.new(canton: '').canton_value.should be_blank
    end

    it 'is locale specific value for valid key' do
      Group.new(canton: 'be').canton_value.should eq 'Bern'
    end
  end

end
