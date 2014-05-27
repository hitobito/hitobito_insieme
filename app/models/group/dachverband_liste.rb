class Group::DachverbandListe < Group

  children Group::DachverbandListe


  ### ROLES

  class Listenverwaltung < ::Role
    self.permissions = [:group_full]
  end

  class Person < ::Role; end

  roles Listenverwaltung,
        Person

end
