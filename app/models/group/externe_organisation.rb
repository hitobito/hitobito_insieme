# encoding: utf-8
# == Schema Information
#
# Table name: groups
#
#  id             :integer          not null, primary key
#  parent_id      :integer
#  lft            :integer
#  rgt            :integer
#  name           :string(255)      not null
#  short_name     :string(31)
#  type           :string(255)      not null
#  email          :string(255)
#  address        :string(1024)
#  zip_code       :integer
#  town           :string(255)
#  country        :string(255)
#  contact_id     :integer
#  created_at     :datetime
#  updated_at     :datetime
#  deleted_at     :datetime
#  layer_group_id :integer
#  creator_id     :integer
#  updater_id     :integer
#  deleter_id     :integer
#


#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class Group::ExterneOrganisation < Group

  self.layer = true
  self.used_attributes += [:full_name, :vid, :bsv_number, :canton]
  self.event_types = [Event, Event::Course]

  children Group::ExterneOrganisation,
           Group::Aktivmitglieder,
           Group::Passivmitglieder,
           Group::Kollektivmitglieder,
           Group::ExterneOrganisationListe,
           Group::ExterneOrganisationGremium


  ### ROLES

  class Praesident < ::Role
    self.permissions = [:contact_data]
  end

  class Geschaeftsfuehrung < ::Role
    self.permissions = [:layer_full, :contact_data]
  end

  class Sekretariat < ::Role
    self.permissions = [:layer_full, :contact_data]
  end

  class Adressverwaltung < ::Role
    self.permissions = [:layer_full, :contact_data]
  end

  class Versandadresse < ::Role
    self.permissions = [:contact_data]
  end

  class Rechnungsadresse < ::Role
    self.permissions = [:contact_data]
  end

  class Controlling < ::Role
    self.permissions = [:contact_data]
  end

  roles Praesident,
        Geschaeftsfuehrung,
        Sekretariat,
        Adressverwaltung,
        Versandadresse,
        Rechnungsadresse,
        Controlling

end
