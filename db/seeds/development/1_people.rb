# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require Rails.root.join('db', 'seeds', 'support', 'person_seeder')

class InsiemePersonSeeder < PersonSeeder

  def amount(role_type)
    case role_type.name.demodulize
    when 'DachverbandListe', 'Aktivmitglieder', 'Passivmitglieder', 'Kollektivmitglieder',
      'MitgliederverbandListe' then 5
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
            'Juerg Reusser']

devs = {}
puzzlers.each do |puz|
  devs[puz] = "#{puz.split.last.downcase}@puzzle.ch"
end

seeder = InsiemePersonSeeder.new

seeder.seed_all_roles

root = Group.root
devs.each do |name, email|
  seeder.seed_developer(name, email, root, Group::Dachverband::Geschaeftsfuehrung)
end

insieme_emails = %w(cschoenbaechler@insieme.ch)

insieme_password = BCrypt::Password.create("insieme14insieme", cost: 1)
insieme_emails.each do |email|
  role_type = Group::Dachverband::Geschaeftsfuehrung
  attrs = seeder.person_attributes(role_type).merge(email: email,
                                                    encrypted_password: insieme_password )
  Person.seed_once(:email, attrs)
  person = Person.find_by_email(attrs[:email])
  role_attrs = { person_id: person.id, group_id: root.id, type: role_type.sti_name }
  Role.seed_once(*role_attrs.keys, role_attrs)
end
