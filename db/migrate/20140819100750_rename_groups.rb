# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class RenameGroups < ActiveRecord::Migration
  def up
    rename(true)
  end

  def down
    rename(false)
  end

  def rename(up)
    # Group types
    rename_group('Group::Dachverband',
                 'Group::Dachverein', up)
    rename_group('Group::DachverbandListe',
                 'Group::DachvereinListe', up)
    rename_group('Group::DachverbandGremium',
                 'Group::DachvereinGremium', up)

    rename_group('Group::Mitgliederverband',
                 'Group::Regionalverein', up)
    rename_group('Group::MitgliederverbandListe',
                 'Group::RegionalvereinListe', up)
    rename_group('Group::MitgliederverbandGremium',
                 'Group::RegionalvereinGremium', up)

    # Role types
    rename_role('Group::Dachverband::Geschaeftsfuehrung',
                'Group::Dachverein::Geschaeftsfuehrung', up)
    rename_role('Group::Dachverband::Sekretariat',
                'Group::Dachverein::Sekretariat', up)
    rename_role('Group::Dachverband::Adressverwaltung',
                'Group::Dachverein::Adressverwaltung', up)

    rename_role('Group::DachverbandListe::Listenverwaltung',
                'Group::DachvereinListe::Listenverwaltung', up)
    rename_role('Group::DachverbandListe::Person',
                'Group::DachvereinListe::Person', up)

    rename_role('Group::DachverbandGremium::Leitung',
                'Group::DachvereinGremium::Leitung', up)
    rename_role('Group::DachverbandGremium::Mitglied',
                'Group::DachvereinGremium::Mitglied', up)

    rename_role('Group::Mitgliederverband::Praesident',
                'Group::Regionalverein::Praesident', up)
    rename_role('Group::Mitgliederverband::Geschaeftsfuehrung',
                'Group::Regionalverein::Geschaeftsfuehrung', up)
    rename_role('Group::Mitgliederverband::Sekretariat',
                'Group::Regionalverein::Sekretariat', up)
    rename_role('Group::Mitgliederverband::Adressverwaltung',
                'Group::Regionalverein::Adressverwaltung', up)
    rename_role('Group::Mitgliederverband::Versandadresse',
                'Group::Regionalverein::Versandadresse', up)
    rename_role('Group::Mitgliederverband::Rechnungsadresse',
                'Group::Regionalverein::Rechnungsadresse', up)
    rename_role('Group::Mitgliederverband::Controlling',
                'Group::Regionalverein::Controlling', up)
  end

  def rename_group(old_type, new_type, up)
    if up
      execute "UPDATE groups SET type = '#{new_type}' WHERE type = '#{old_type}'"
    else
      execute "UPDATE groups SET type = '#{old_type}' WHERE type = '#{new_type}'"
    end
  end

  def rename_role(old_type, new_type, up)
    if up
      execute "UPDATE roles SET type = '#{new_type}' WHERE type = '#{old_type}'"
    else
      execute "UPDATE roles SET type = '#{old_type}' WHERE type = '#{new_type}'"
    end
  end
end
