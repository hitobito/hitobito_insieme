# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.
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

  context 'canton_label' do

    it 'is blank for nil value' do
      expect(Group.new.canton_label).to be_blank
    end

    it 'is blank for blank value' do
      expect(Group.new(canton: '').canton_label).to be_blank
    end

    it 'is locale specific value for valid key' do
      expect(Group.new(canton: 'be').canton_label).to eq 'Bern'
    end
  end

end
