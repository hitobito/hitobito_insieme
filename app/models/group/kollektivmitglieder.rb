class Group::Kollektivmitglieder < Group

  self.layer = true

  children Group::Kollektivmitglieder


  ### ROLES

  class Kollektivmitglied < ::Role; end

  class KollektivmitgliedOhneAbo < ::Role; end

  roles Kollektivmitglied,
        KollektivmitgliedOhneAbo

end
