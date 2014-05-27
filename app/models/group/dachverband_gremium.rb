class Group::DachverbandGremium < Group

  children Group::DachverbandGremium


  ### ROLES

  class Leitung < ::Role
    self.permissions = [:group_full, :contact_data]
  end

  class Mitglied < ::Role
    self.permissions = [:group_read]
  end

  roles Leitung,
        Mitglied

end
