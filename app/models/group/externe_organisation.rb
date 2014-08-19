# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class Group::ExterneOrganisation < Group

  self.layer = true
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
