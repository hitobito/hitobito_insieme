# frozen_string_literal: true

#  Copyright (c) 2012-2022, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.
# == Schema Information
#
# Table name: groups
#
#  id                          :integer          not null, primary key
#  parent_id                   :integer
#  lft                         :integer
#  rgt                         :integer
#  name                        :string(255)      not null
#  short_name                  :string(31)
#  type                        :string(255)      not null
#  email                       :string(255)
#  address                     :string(1024)
#  zip_code                    :integer
#  town                        :string(255)
#  country                     :string(255)
#  contact_id                  :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  deleted_at                  :datetime
#  layer_group_id              :integer
#  creator_id                  :integer
#  updater_id                  :integer
#  deleter_id                  :integer
#  full_name                   :string(255)
#  vid                         :integer
#  bsv_number                  :integer
#  canton                      :string(255)
#  require_person_add_requests :boolean          default(FALSE), not null
#

class Group::Passivmitglieder < Group
  children Group::Passivmitglieder

  ### ROLES

  class Passivmitglied < ::Role; end

  class PassivmitgliedMitAbo < ::Role; end

  roles Passivmitglied,
    PassivmitgliedMitAbo

  self.default_role = PassivmitgliedMitAbo
end
