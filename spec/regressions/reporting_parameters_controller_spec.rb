# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe ReportingParametersController, type: :controller do

  class << self
    def it_should_redirect_to_show
      it { is_expected.to redirect_to reporting_parameters_path(returning: true) }
    end
  end

  let(:test_entry) { reporting_parameters(:p2014) }
  let(:test_entry_attrs) do
    { year: 2015,
      vollkosten_le_schwelle1_blockkurs: 440,
      vollkosten_le_schwelle2_blockkurs: 600,
      vollkosten_le_schwelle1_tageskurs: 300,
      vollkosten_le_schwelle2_tageskurs: 450,
      bsv_hours_per_year: 1900,
      capital_substrate_exemption: 200_000 }
  end

  before { sign_in(people(:top_leader)) }

  include_examples 'crud controller', skip: [%w(show)]

end
