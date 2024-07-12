#  Copyright (c) 2016, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe TimeRecord::BaseInformationsController, type: :controller do
  render_views

  before { sign_in(people(:top_leader)) }

  it "raises 404 for unsupported group type" do
    expect do
      get :index, params: {id: groups(:aktiv).id, year: 2014}
    end.to raise_error(CanCan::AccessDenied)
  end

  it "shows base information" do
    get :index, params: {id: groups(:dachverein).id, year: 2014}
    is_expected.to render_template("index")
  end

  it "exports csv" do
    get :index, params: {id: groups(:dachverein).id, year: 2014}, format: :csv
    csv = response.body
    expect(csv).to match(Regexp.new("\\A#{Export::Csv::UTF8_BOM};Art. 74 betreffend;Art. 74 nicht betreffend;Ganze Organisation"))
    expect(csv).to match(/^Angestellte MitarbeiterInnen\. Gemäss Arbeitsvertrag \(in 100% Stellen\);;;0\.0$/)
  end
end
