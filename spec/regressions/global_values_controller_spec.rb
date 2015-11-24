# encoding: utf-8

#  Copyright (c) 2012-2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe GlobalValuesController, type: :controller do

  class << self
    def it_should_redirect_to_show
      it { is_expected.to redirect_to edit_global_value_path }
    end
  end

  let(:test_entry) { global_values(:a) }

  let(:test_entry_attrs) do
    { default_reporting_year: 2010 }
  end

  before { sign_in(people(:top_leader)) }

  include_examples 'crud controller', skip: [%w(index), %w(show), %w(new), %w(create), %w(destroy)]

end
