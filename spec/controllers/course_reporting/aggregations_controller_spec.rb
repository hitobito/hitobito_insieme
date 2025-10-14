#  Copyright (c) 2015-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe CourseReporting::AggregationsController do
  let(:group) { groups(:dachverein) }

  before { sign_in(people(:top_leader)) }

  render_views

  it "index page renders ok" do
    get :index, params: {id: group.id, year: 2014}
    expect(response).to be_ok
  end

  it "export renders ok" do
    get :export,
      params: {id: group.id, year: 2014, lk: "bk", subsidized: "true", categories: [1, 2, 3]}
    expect(response).to be_ok

    filename = "course_statistics_bsv2343_insieme-schweiz_2014_blockkurse_subsidized_1_2_3.csv"

    header = response.headers["Content-Disposition"]
    expect(header).to match(/^attachment;/)
    expect(header).to match(/filename="#{filename}";/)
    expect(header).to match(/filename\*=UTF-8''#{filename}/)
  end

  it "export renders consolidated if allowed" do
    get :export,
      params: {id: group.id, year: 2014, lk: "bk", subsidized: "true", categories: [1, 2, 3],
               consolidate: true}
    expect(response).to be_ok

    # rubocop:todo Layout/LineLength
    filename = "course_statistics_bsv2343_insieme-schweiz_2014_blockkurse_subsidized_1_2_3_consolidated.csv"
    # rubocop:enable Layout/LineLength

    header = response.headers["Content-Disposition"]
    expect(header).to match(/^attachment;/)
    expect(header).to match(/filename="#{filename}";/)
    expect(header).to match(/filename\*=UTF-8''#{filename}/)
  end

  it "export does not render consolidated if not allowed" do
    sign_in(Fabricate(Group::Regionalverein::Geschaeftsfuehrung.name, group: groups(:be)).person)

    get :export,
      params: {id: groups(:be).id, year: 2014, lk: "bk", subsidized: "true", categories: [1, 2, 3],
               consolidate: true}
    expect(response).to be_ok

    filename = "course_statistics_bsv2024_kanton-bern_2014_blockkurse_subsidized_1_2_3.csv"

    header = response.headers["Content-Disposition"]
    expect(header).to match(/^attachment;/)
    expect(header).to match(/filename="#{filename}";/)
    expect(header).to match(/filename\*=UTF-8''#{filename}/)
  end
end
