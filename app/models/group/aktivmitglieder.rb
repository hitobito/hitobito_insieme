class Group::Aktivmitglieder < Group

  self.layer = true

  children Group::Aktivmitglieder


  ### ROLES

  class Aktivmitglied < ::Role; end

  class AktivmitgliedOhneAbo < ::Role; end

  class Zweitmitgliedschaft < ::Role; end

  roles Aktivmitglied,
        AktivmitgliedOhneAbo,
        Zweitmitgliedschaft
end
