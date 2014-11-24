# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Export::Csv::People
  module PeopleFull
    extend ActiveSupport::Concern

    included do
      alias_method_chain :person_attribute_labels, :insieme
      alias_method_chain :person_attributes, :insieme
    end

    def person_attributes_with_insieme
      person_attributes_without_insieme + [:reference_person_first_name,
                                           :reference_person_last_name,
                                           :reference_person_active_membership_roles]
    end

    def person_attribute_labels_with_insieme
      labels = person_attribute_labels_without_insieme
      labels[:reference_person_first_name] = person_human(:reference_person_first_name)
      labels[:reference_person_last_name] = person_human(:reference_person_last_name)
      labels[:reference_person_active_membership_roles] =
      person_human(:reference_person_active_membership_roles)
      labels
    end

    private

    def person_human(attr)
      ::Person.human_attribute_name(attr)
    end

  end
end
