# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'


describe GroupAbility do

  context 'Dachverein' do
    %w(Geschaeftsfuehrung Sekretariat Adressverwaltung).each do |role_class|
      it "#{role_class} may :reporting on same group" do
        ability(groups(:dachverein),
                "Group::Dachverein::#{role_class}".constantize).
                should be_able_to(:reporting, groups(:dachverein))
      end

      it "#{role_class} may :reporting on layer below" do
        ability(groups(:dachverein),
                "Group::Dachverein::#{role_class}".constantize).
                should be_able_to(:reporting, groups(:be))
      end
    end
  end

  context 'Regionalverein' do
    %w(Praesident Versandadresse Rechnungsadresse).each do |role_class|
      it "#{role_class} may not :reporting on same group" do
        ability(groups(:be),
                "Group::Regionalverein::#{role_class}".constantize).
                should_not be_able_to(:reporting, groups(:be))
      end
    end

    %w(Geschaeftsfuehrung Sekretariat Adressverwaltung Controlling).each do |role_class|
      it "#{role_class} may :reporting on same group" do
        ability(groups(:be),
                "Group::Regionalverein::#{role_class}".constantize).
                should be_able_to(:reporting, groups(:be))
      end

      it "#{role_class} may not :reporting on layer above" do
        ability(groups(:be),
                "Group::Regionalverein::#{role_class}".constantize).
                should_not be_able_to(:reporting, groups(:dachverein))
      end

      it "#{role_class} may not :reporting on different group on same layer" do
        ability(groups(:be),
                "Group::Regionalverein::#{role_class}".constantize).
                should_not be_able_to(:reporting, groups(:fr))
      end
    end
  end

  def ability(group, role_type)
    role = Fabricate(role_type.name.to_sym, group: group)
    Ability.new(role.person.reload)
  end

end
