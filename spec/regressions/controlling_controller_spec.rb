#  Copyright (c) 2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe ControllingController, type: :controller do
  render_views

  before { sign_in(people(:top_leader)) }

  it "raises 404 for unsupported group type" do
    expect do
      get :index, params: {id: groups(:aktiv).id}
    end.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "shows index" do
    get :index, params: {id: groups(:dachverein).id}
    is_expected.to render_template("index")
  end

  context "GET client_statistics.csv" do
    before { get :client_statistics, params: {id: groups(:dachverein), year: 2014}, format: :xlsx }

    it "exports table" do
      # rubocop:todo Layout/LineLength
      expect(@response.body).to match(/Personen mit Behinderung \/ Kanton;Blockkurse Anzahl Personen mit Behinderung;Blockkurse /)
      # rubocop:enable Layout/LineLength
    end
  end

  context "GET time_records.csv" do
    before do
      get :time_records,
        params: {
          id: groups(:dachverein),
          year: 2014,
          type: TimeRecord::EmployeeTime.sti_name
        },
        format: :csv
    end

    it "exports table" do
      # rubocop:todo Layout/LineLength
      expect(@response.body).to match(Regexp.new("^#{Export::Csv::UTF8_BOM}Gruppe;Kontakte zu Medien, zu Medienschaffenden;.+;Total$"))
      # rubocop:enable Layout/LineLength
      # rubocop:todo Layout/LineLength
      expect(@response.body).to match(/^insieme Schweiz;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;$/)
      # rubocop:enable Layout/LineLength
      expect(@response.body).to match(/^Kanton Bern;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;$/)
    end
  end
end
