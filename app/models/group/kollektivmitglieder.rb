class Group::Kollektivmitglieder < Group

  self.layer = true

  children Group::Kollektivmitglieder


  ### ROLES

  class Kollektivmitglied < ::Role; end

  class KollektivmitgliedMitAbo < ::Role; end

  roles Kollektivmitglied,
        KollektivmitgliedMitAbo

end
