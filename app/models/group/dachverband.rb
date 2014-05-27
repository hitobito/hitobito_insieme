class Group::Dachverband < Group

  self.layer = true

  children Group::DachverbandListe,
           Group::DachverbandGremium,
           Group::Mitgliederverband


  ### ROLES

  class Geschaeftsfuehrung < ::Role
    self.permissions = [:layer_full, :contact_data]
  end

  class Sekretariat < ::Role
    self.permissions = [:layer_full, :contact_data]
  end

  class Adressverwaltung < ::Role
    self.permissions = [:layer_full, :contact_data]
  end

  roles Geschaeftsfuehrung,
        Sekretariat,
        Adressverwaltung

end
