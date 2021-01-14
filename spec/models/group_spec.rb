# frozen_string_literal: true

#  Copyright (c) 2012-2021, insieme Schweiz. This file is part of
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
        [
          Group::Dachverein,
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

  context '#by_bsv_number' do
    subject { Group.by_bsv_number }

    it 'is a scope returning groups' do
      expect(subject.all).to all(be_a Group)
    end

    it 'returns the Dachverein first' do
      expect(subject.first).to eq groups(:dachverein)
    end

    it 'returns only groups with BSV-Number' do
      fr = groups(:fr).update(bsv_number: nil)

      expect(subject.all).to_not include fr
      expect(subject.all).to_not include groups(:aktiv)
    end

    it 'returns groups in order of ascending BSV-Number' do
      expect(subject.all).to match_array [
        groups(:dachverein), # 2343, but always first
        groups(:be),         # 2024
        groups(:seeland),    # 3115
        groups(:fr)          # 12607
      ]
    end
  end
end
