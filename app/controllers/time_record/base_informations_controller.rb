# frozen_string_literal: true

#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class TimeRecord::BaseInformationsController < ReportingBaseController

  include Rememberable
  include Vertragsperioden::Domain

  self.remember_params = [:year]

  before_action :entry, except: :index

  def index
    @table = vp_class('TimeRecord::Table').new(group, year)

    respond_to do |format|
      format.html
      format.csv do
        send_data Export::Tabular::TimeRecords::BaseInformation.csv(@table), type: :csv
      end
    end
  end

end
