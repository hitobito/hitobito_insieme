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

        should include(pa)
        should include(people(:regio_aktiv))
        should include(abo)
        should_not include(pm)
        should_not include(extern)
      end

      it 'contains no duplicate' do
        abos = Fabricate(Group::DachvereinAbonnemente.name.to_sym, parent: groups(:dachverein))
        Fabricate(Group::DachvereinAbonnemente::Einzelabo.name.to_sym,
                  group: abos,
                  person: people(:regio_aktiv))

        should have(1).item
      end

      it 'does not contain deleted roles' do
        abos = Fabricate(Group::DachvereinAbonnemente.name.to_sym, parent: groups(:dachverein))
        abo = Fabricate(Group::DachvereinAbonnemente::Einzelabo.name.to_sym, group: abos).person
        abo.roles.first.update!(deleted_at: 1.year.ago)

        should_not include(abo)
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

        should include(abo1)
        should include(people(:regio_aktiv))
        should include(abo3)
        should_not include(abo2)
      end

      it 'contains person if country is null' do
        people(:regio_aktiv).update!(country: nil)
        should include(people(:regio_aktiv))
      end

      it 'contains person if country is empty' do
        people(:regio_aktiv).update!(country: '  ')
        should include(people(:regio_aktiv))
      end

      it 'contains person if country is Schweiz' do
        people(:regio_aktiv).update!(country: 'Schweiz')
        should include(people(:regio_aktiv))
      end

      it 'contains person if country is suisse' do
        people(:regio_aktiv).update!(country: 'SUISSE ')
        should include(people(:regio_aktiv))
      end

      it 'contains person if country is ch' do
        people(:regio_aktiv).update!(country: ' ch ')
        should include(people(:regio_aktiv))
      end

      it 'does not contain person if country is DE' do
        people(:regio_aktiv).update!(country: 'DE')
        should_not include(people(:regio_aktiv))
      end
    end

    context 'fr' do
      let(:language) { 'fr' }

      it 'contains person if language is fr' do
        people(:regio_aktiv).update!(correspondence_language: 'fr')
        should include(people(:regio_aktiv))
      end

      it 'does not contain person if language is null' do
        people(:regio_aktiv).update!(correspondence_language: nil)
        should_not include(people(:regio_aktiv))
      end

      it 'does not contain person if language is de' do
        people(:regio_aktiv).update!(correspondence_language: 'de')
        should_not include(people(:regio_aktiv))
      end
    end
  end

  context 'other' do
    let(:swiss) { false }

    it 'contains person if country is de' do
      people(:regio_aktiv).update!(country: ' de ')
      should include(people(:regio_aktiv))
    end

    it 'contains person if country is 123' do
      people(:regio_aktiv).update!(country: '123')
      should include(people(:regio_aktiv))
    end

    it 'does not contain person if country is ch' do
      people(:regio_aktiv).update!(country: 'CH')
      should_not include(people(:regio_aktiv))
    end

    it 'does not contain person if country is empty' do
      people(:regio_aktiv).update!(country: '')
      should_not include(people(:regio_aktiv))
    end

    it 'does not contain person if country is null' do
      people(:regio_aktiv).update!(country: nil)
      should_not include(people(:regio_aktiv))
    end
  end

end
