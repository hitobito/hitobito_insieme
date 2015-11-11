# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe AboAddresses::Query do

  let(:language) { 'de' }
  let(:swiss) { true }

  let(:query) { described_class.new(swiss, language) }

  subject { query.people }

  context 'swiss' do
    context 'de' do

      it 'contains only included roles and layers' do
        passive = Fabricate(Group::Passivmitglieder.name.to_sym, parent: groups(:be))
        pm = Fabricate(Group::Passivmitglieder::Passivmitglied.name.to_sym, group: passive).person
        pa = Fabricate(Group::Passivmitglieder::PassivmitgliedMitAbo.name.to_sym, group: passive).person
        abos = Fabricate(Group::DachvereinAbonnemente.name.to_sym, parent: groups(:dachverein))
        abo = Fabricate(Group::DachvereinAbonnemente::Einzelabo.name.to_sym, group: abos).person
        externals = Fabricate(Group::ExterneOrganisation.name.to_sym, parent: groups(:dachverein))
        e_active = Fabricate(Group::Aktivmitglieder.name.to_sym, parent: externals)
        extern = Fabricate(Group::Aktivmitglieder::Aktivmitglied.name.to_sym, group: e_active).person

        is_expected.to include(pa)
        is_expected.to include(people(:regio_aktiv))
        is_expected.to include(abo)
        is_expected.not_to include(pm)
        is_expected.not_to include(extern)
      end

      it 'contains no duplicate' do
        abos = Fabricate(Group::DachvereinAbonnemente.name.to_sym, parent: groups(:dachverein))
        Fabricate(Group::DachvereinAbonnemente::Einzelabo.name.to_sym,
                  group: abos,
                  person: people(:regio_aktiv))

        is_expected.to have(1).item
      end

      it 'does not contain deleted roles' do
        abos = Fabricate(Group::DachvereinAbonnemente.name.to_sym, parent: groups(:dachverein))
        abo = Fabricate(Group::DachvereinAbonnemente::Einzelabo.name.to_sym, group: abos).person
        abo.roles.first.update!(deleted_at: 1.year.ago)

        is_expected.not_to include(abo)
      end

      it 'contains empty correspondence_language as well' do
        abos = Fabricate(Group::DachvereinAbonnemente.name.to_sym, parent: groups(:dachverein))
        abo1 = Fabricate(Group::DachvereinAbonnemente::Einzelabo.name.to_sym, group: abos).person
        abo2 = Fabricate(Group::DachvereinAbonnemente::Einzelabo.name.to_sym, group: abos).person
        abo3 = Fabricate(Group::DachvereinAbonnemente::Einzelabo.name.to_sym, group: abos).person
        abo1.update!(correspondence_language: nil)
        abo2.update!(correspondence_language: 'fr')
        abo3.update!(correspondence_language: '')
        people(:regio_aktiv).update!(correspondence_language: 'de')

        is_expected.to include(abo1)
        is_expected.to include(people(:regio_aktiv))
        is_expected.to include(abo3)
        is_expected.not_to include(abo2)
      end

      it 'contains person if country is null' do
        people(:regio_aktiv).update!(country: nil)
        is_expected.to include(people(:regio_aktiv))
      end

      it 'contains person if country is empty' do
        people(:regio_aktiv).update!(country: '  ')
        is_expected.to include(people(:regio_aktiv))
      end

      it 'contains person if country is Schweiz' do
        people(:regio_aktiv).update!(country: 'CH')
        is_expected.to include(people(:regio_aktiv))
      end

      it 'does not contain person if country is DE' do
        people(:regio_aktiv).update!(country: 'DE')
        is_expected.not_to include(people(:regio_aktiv))
      end
    end

    context 'fr' do
      let(:language) { 'fr' }

      it 'contains person if language is fr' do
        people(:regio_aktiv).update!(correspondence_language: 'fr')
        is_expected.to include(people(:regio_aktiv))
      end

      it 'does not contain person if language is null' do
        people(:regio_aktiv).update!(correspondence_language: nil)
        is_expected.not_to include(people(:regio_aktiv))
      end

      it 'does not contain person if language is de' do
        people(:regio_aktiv).update!(correspondence_language: 'de')
        is_expected.not_to include(people(:regio_aktiv))
      end
    end
  end

  context 'other' do
    let(:swiss) { false }

    it 'contains person if country is de' do
      people(:regio_aktiv).update!(country: 'DE')
      is_expected.to include(people(:regio_aktiv))
    end

    it 'does not contain person if country is ch' do
      people(:regio_aktiv).update!(country: 'CH')
      is_expected.not_to include(people(:regio_aktiv))
    end

    it 'does not contain person if country is empty' do
      people(:regio_aktiv).update!(country: '')
      is_expected.not_to include(people(:regio_aktiv))
    end

    it 'does not contain person if country is null' do
      people(:regio_aktiv).update!(country: nil)
      is_expected.not_to include(people(:regio_aktiv))
    end
  end

end
