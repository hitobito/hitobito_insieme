# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Statistics::Vereinsmitglieder do

  let(:vereinsmitglieder) { described_class.new }

  context '#vereine' do
    subject { vereinsmitglieder.vereine }

    it 'contains only Regionalvereine' do
      subject.all? { |g| g.is_a?(Group::Regionalverein) }.should be true
    end
  end

  context '#count' do

    subject { vereinsmitglieder }

    let(:layer) { groups(:be) }

    let(:active) { Fabricate(Group::Aktivmitglieder.name.to_sym, parent: layer) }
    let(:passive) { Fabricate(Group::Passivmitglieder.name.to_sym, parent: layer) }
    let(:collective) { Fabricate(Group::Kollektivmitglieder.name.to_sym, parent: layer) }

    it 'counts all member roles in layer' do
      subject.role_types do |role, index|
        index.times { Fabricate(role.name.to_sym, group: role_group(role)) }
      end

      subject.role_types do |role, index|
        subject.count(layer, index).should eq index
      end
    end

    it 'counts people only in sub layer' do
      subject.count(layer, 0).should eq 0
      subject.count(groups(:seeland), 0).should eq 1
    end

    it 'counts people with roles in two layers twice' do
      Fabricate(Group::Aktivmitglieder::Aktivmitglied.name.to_sym,
                group: active,
                person: people(:regio_aktiv))

      subject.count(layer, 0).should eq 1
      subject.count(groups(:seeland), 0).should eq 1
    end

    it 'counts people with multiple roles in one layer only once' do
      Fabricate(Group::Aktivmitglieder::AktivmitgliedOhneAbo.name.to_sym,
                group: active,
                person: people(:regio_aktiv))
      Fabricate(Group::Kollektivmitglieder::Kollektivmitglied.name.to_sym,
                group: collective,
                person: people(:regio_aktiv))
      Fabricate(Group::Passivmitglieder::PassivmitgliedMitAbo.name.to_sym,
                group: passive,
                person: people(:regio_aktiv))

      subject.count(layer, 0).should eq 0
      subject.count(layer, 1).should eq 1
      (2..6).each { |i| subject.count(layer, i).should eq 0 }

      subject.count(groups(:seeland), 0).should eq 1
      (1..6).each { |i| subject.count(groups(:seeland), i).should eq 0 }
    end

    it 'does not count deleted roles' do
      o = Fabricate(Group::Aktivmitglieder::Aktivmitglied.name.to_sym, group: active)
      a = Fabricate(Group::Aktivmitglieder::AktivmitgliedOhneAbo.name.to_sym,
                    group: active,
                    person: people(:regio_aktiv))
      b = Fabricate(Group::Passivmitglieder::PassivmitgliedMitAbo.name.to_sym,
                    group: passive,
                    person: people(:regio_aktiv))
      o.update!(deleted_at: 1.year.ago)
      a.update!(deleted_at: 1.year.ago)

      (0..5).each { |i| subject.count(layer, i).should eq 0 }
      subject.count(layer, 6).should eq 1
    end

    def role_group(role)
      case role.name
      when /Group::Aktivmitglieder/ then active
      when /Group::Passivmitglieder/ then passive
      when /Group::Kollektivmitglieder/ then collective
      else fail("could not match role #{role.name}")
      end
    end
  end

end