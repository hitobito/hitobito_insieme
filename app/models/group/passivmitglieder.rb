class Group::Passivmitglieder < Group

  self.layer = true

  children Group::Passivmitglieder


  ### ROLES

  class Passivmitglied < ::Role; end

  class PassivmitgliedMitAbo < ::Role; end

  roles Passivmitglied,
        PassivmitgliedMitAbo

end
