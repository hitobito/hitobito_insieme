# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require Rails.root.join('db', 'seeds', 'support', 'person_seeder')

class InsiemePersonSeeder < PersonSeeder

  def amount(role_type)
    case role_type.name.demodulize
    when 'Person', 'Mitglied', 'Aktivmitglied', 'Passivmitglied' then 5
    else 1
    end
  end

end

puzzlers = ['Pascal Zumkehr',
            'Pierre Fritsch',
            'Andreas Maierhofer',
            'Andre Kunz',
            'Roland Studer',
            'Mathis Hofer',
            'Bruno Santschi']

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
