# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe PeopleController do
  it 'should permit the prefixed address attributes' do
    expect(PeopleController.permitted_attrs).to include(:correspondence_general_name)
    expect(PeopleController.permitted_attrs).to include(:billing_general_name)
    expect(PeopleController.permitted_attrs).to include(:correspondence_course_name)
    expect(PeopleController.permitted_attrs).to include(:billing_course_name)
    expect(PeopleController.permitted_attrs).to include(:correspondence_general_company_name)
  end
end
