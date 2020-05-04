# encoding: utf-8

#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'test_helper'
require 'relevance/tarantula'
require 'tarantula/tarantula_config'

class TarantulaTest < ActionDispatch::IntegrationTest
  # Load enough test data to ensure that there's a link to every page in your
  # application. Doing so allows Tarantula to follow those links and crawl
  # every page.  For many applications, you can load a decent data set by
  # loading all fixtures.

  reset_fixture_path File.expand_path('../../../spec/fixtures', __FILE__)

  include TarantulaConfig

  def test_tarantula_as_verbandsleitung
    crawl_as(people(:top_leader))
  end

  def test_tarantula_as_regionalleitung
    crawl_as(people(:regio_leader))
  end

  def test_tarantula_as_aktivmitglied
    crawl_as(people(:regio_aktiv))
  end

  private

  def configure_urls(t, person)
    super(t, person)

    t.skip_uri_patterns << /groups\/\d+\/cost_accounting\/#{outside_three_years_window}/
    t.skip_uri_patterns << /groups\/\d+\/time_record\/#{outside_three_years_window}/
    t.skip_uri_patterns << /groups\/\d+\/capital_substrate\/#{outside_three_years_window}/

    # already deleted in another language
    t.allow_404_for << /reporting_parameters\/\d+$/
  end

end
