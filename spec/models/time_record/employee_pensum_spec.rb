# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe TimeRecord::EmployeePensum do

  context '#total' do
    it 'is 0 for new record' do
      expect(TimeRecord::EmployeePensum.new.total).to eq 0
    end

    it 'is the sum paragraph 74 and not paragraph 74 pensums' do
      pensum = TimeRecord::EmployeePensum.new(paragraph_74: 1.5, not_paragraph_74: 2.4)
      expect(pensum.total).to eq 3.9
    end
  end

end
