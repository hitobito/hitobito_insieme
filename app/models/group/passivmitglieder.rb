class Group::Passivmitglieder < Group

  self.layer = true

  children Group::Passivmitglieder


  ### ROLES

  class PassivesMitglied < ::Role; end

  class PassivesMitgliedOhneAbo < ::Role; end

  roles PassivesMitglied,
        PassivesMitgliedOhneAbo

end
