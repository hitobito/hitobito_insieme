# -*- coding: utf-8 -*-
require Rails.root.join('db', 'seeds', 'support', 'group_seeder')

$seeder = GroupSeeder.new

dachverband = Group.roots.first
srand(42)

unless dachverband.address.present?
 dachverband.update_attributes($seeder.group_attributes)
 dachverband.default_children.each do |child_class|
   child_class.first.update_attributes($seeder.group_attributes)
 end
end

def seed_group(group, *attrs)
  with_group_attributes = attrs.map { |attr| attr.merge($seeder.group_attributes) }
  group.seed(:name, :parent_id, *with_group_attributes)
end

seed_group(Group::DachverbandListe,
  {name: 'Partnerorganisationen',
   parent_id: dachverband.id},
  {name: 'Übersetzer',
   parent_id: dachverband.id}
)

seed_group(Group::DachverbandGremium, {
  name: 'Kommission 74',
  parent_id: dachverband.id
})

be, fr = seed_group(Group::Mitgliederverband,
  {name: 'Kanton Bern',
   short_name: 'BE',
   address: 'Seilerstr. 27',
   zip_code: 3011,
   town: 'Bern',
   country: 'Schweiz',
   email: 'be@example.com',
   parent_id: dachverband.id, },

  {name: 'Freiburg',
   short_name: 'FR',
   address: 'Route de Moncor 14',
   zip_code: 1701,
   town: 'Fribourg',
   country: 'Schweiz',
   email: 'fr@example.com',
   parent_id: dachverband.id})

oberland, seeland = seed_group(Group::Mitgliederverband,
  {name: 'Thun Oberland',
   short_name: 'BEO',
   address: 'Im Gwatt 12',
   zip_code: 3600,
   town: 'Thun',
   country: 'Schweiz',
   email: 'beo@example.com',
   parent_id: be.id, },

  {name: 'Biel-Seeland',
   short_name: 'BNC',
   address: 'Unterer Quai 42',
   zip_code: 2500,
   town: 'Biel/Bienne',
   country: 'Schweiz',
   email: 'bnc@example.com',
   parent_id: be.id})

[be, fr, oberland, seeland].each do |s|
  $seeder.seed_social_accounts(s)
end

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

seed_group(Group::MitgliederverbandListe, {
  name: 'Kursbetreuer',
  parent_id: seeland.id})

Group.rebuild!
