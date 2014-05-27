require 'spec_helper'

describe Group do
  include_examples 'group types'


  describe '#all_types' do
    subject { Group.all_types }

    it 'is in hierarchical order' do
      expect(subject.collect(&:name)).to eq(
        [Group::Dachverband,
         Group::Mitgliederverband,
         Group::Aktivmitglieder,
         Group::Passivmitglieder,
         Group::Kollektivmitglieder,
         Group::MitgliederverbandGremium,
         Group::MitgliederverbandListe,
         Group::DachverbandGremium,
         Group::DachverbandListe].collect(&:name))
    end
  end


end
