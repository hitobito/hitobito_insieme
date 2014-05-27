class Group::Mitgliederverband < Group

  self.layer = true

  children Group::Mitgliederverband,
           Group::Aktivmitglieder,
           Group::Passivmitglieder,
           Group::Kollektivmitglieder,
           Group::MitgliederverbandListe,
           Group::MitgliederverbandGremium


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
