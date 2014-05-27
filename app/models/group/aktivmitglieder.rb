class Group::Aktivmitglieder < Group

  self.layer = true

  children Group::Aktivmitglieder


  ### ROLES

  class AktivesMitglied < ::Role; end

  class AktivesMitgliedOhneAbo < ::Role; end

  class Zweitmitgliedschaft < ::Role; end

  roles AktivesMitglied,
        AktivesMitgliedOhneAbo,
        Zweitmitgliedschaft
end
