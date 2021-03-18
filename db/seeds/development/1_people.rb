#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require Rails.root.join('db', 'seeds', 'support', 'person_seeder')

class InsiemePersonSeeder < PersonSeeder

  def amount(role_type)
    case role_type.name.demodulize
    when 'Person', 'Mitglied', 'Aktivmitglied', 'Passivmitglied' then 3
    else 1
    end
  end

end

puzzlers = [
  'Andre Kunz',
  'Andreas Maierhofer',
  'Bruno Santschi',
  'Janiss Binder',
  'Mathis Hofer',
  'Matthias Viehweger',
  'Pascal Simon',
  'Pascal Zumkehr',
  'Pierre Fritsch',
  'Roland Studer',
]

devs = {}
puzzlers.each do |puz|
  devs[puz] = "#{puz.split.last.downcase}@puzzle.ch"
end

seeder = InsiemePersonSeeder.new

seeder.seed_all_roles

root = Group.root
devs.each do |name, email|
  seeder.seed_developer(name, email, root, Group::Dachverein::Geschaeftsfuehrung)
end

seeder.assign_role_to_root(root, Group::Dachverein::Geschaeftsfuehrung)

insieme_users = [
  { email: 'cschoenbaechler@insieme.ch',
    role: Group::Dachverein::Geschaeftsfuehrung,
    group: root },
  { email: 'sekretariat@insieme-kantonbern.ch',
    role: Group::Regionalverein::Geschaeftsfuehrung,
    group: Group.where(name: 'Kanton Bern').first },
  { email: 'info@insieme-bern.ch',
    role: Group::Regionalverein::Geschaeftsfuehrung,
    group: Group.where(name: 'Region Bern').first }
]

insieme_password = BCrypt::Password.create("insieme14insieme", cost: 1)
insieme_users.each do |user|
  attrs = seeder.person_attributes(user[:role]).merge(email: user[:email],
                                                    encrypted_password: insieme_password )
  Person.seed_once(:email, attrs)
  person = Person.find_by_email(attrs[:email])
  role_attrs = { person_id: person.id,
                 group_id: user[:group].id,
                 type: user[:role].sti_name }
  Role.seed_once(*role_attrs.keys, role_attrs)
end
