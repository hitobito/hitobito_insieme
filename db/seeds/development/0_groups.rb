# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# -*- coding: utf-8 -*-
require Rails.root.join('db', 'seeds', 'support', 'group_seeder')

$seeder = GroupSeeder.new

dachverein = Group.roots.first
srand(42)

unless dachverein.address.present?
  # avoid callbacks to prevent creating default groups twice
  dachverein.update_columns($seeder.group_attributes)

  dachverein.default_children.each do |child_class|
    child_class.first.update_attributes($seeder.group_attributes)
  end
end

def seed_group(group, *attrs)
  with_group_attributes = attrs.map { |attr| attr.merge($seeder.group_attributes) }
  group.seed(:name, :parent_id, *with_group_attributes)
end

seed_group(Group::DachvereinListe,
  {name: 'Partnerorganisationen',
   parent_id: dachverein.id},
  {name: 'Übersetzer',
   parent_id: dachverein.id}
)

seed_group(Group::DachvereinGremium, {
  name: 'Kommission 74',
  parent_id: dachverein.id
})

be, fr = seed_group(Group::Regionalverein,
  {name: 'Kanton Bern',
   short_name: 'BE',
   address: 'Seilerstr. 27',
   zip_code: 3011,
   town: 'Bern',
   country: 'Schweiz',
   email: 'be@example.com',
   parent_id: dachverein.id, },

  {name: 'Freiburg',
   short_name: 'FR',
   address: 'Route de Moncor 14',
   zip_code: 1701,
   town: 'Fribourg',
   country: 'Schweiz',
   email: 'fr@example.com',
   parent_id: dachverein.id})

seeland, bern = seed_group(Group::Regionalverein,

  {name: 'Biel-Seeland',
   short_name: 'BNC',
   address: 'Unterer Quai 42',
   zip_code: 2500,
   town: 'Biel/Bienne',
   country: 'Schweiz',
   email: 'bnc@example.com',
   parent_id: be.id},

  {name: 'Region Bern',
   short_name: 'RBE',
   address: 'Effingerstrasse 123',
   zip_code: 3000,
   town: 'Bern',
   country: 'Schweiz',
   email: 'rbe@example.com',
   parent_id: be.id})

[be, fr, seeland, bern].each do |s|
  $seeder.seed_social_accounts(s)
end

seed_group(Group::ExterneOrganisation,
  {name: 'Stiftung Arkadis',
   short_name: 'SA',
   parent_id: dachverein.id})

aktiv = seed_group(Group::Aktivmitglieder, {
  name: 'Aktivmitglieder',
  parent_id: seeland.id})[0]

seed_group(Group::Aktivmitglieder,
  {name: 'Elternmitglieder',
   parent_id: aktiv.id},
  {name: 'Behindertenmitglieder',
   parent_id: aktiv.id})

passiv = seed_group(Group::Passivmitglieder, {
  name: 'Passivmitglieder',
  parent_id: seeland.id})[0]

seed_group(Group::Passivmitglieder, {
  name: 'Ehrenmitglieder',
  parent_id: passiv.id})

seed_group(Group::Kollektivmitglieder, {
  name: 'Kollektivmitglieder',
  parent_id: seeland.id})

seed_group(Group::RegionalvereinListe, {
  name: 'Kursbetreuer',
  parent_id: seeland.id})

Group.rebuild!
