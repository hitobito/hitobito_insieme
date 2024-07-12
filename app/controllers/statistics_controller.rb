# frozen_string_literal: true

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class StatisticsController < ApplicationController
  before_action :authorize

  decorates :group

  respond_to :html

  def index
    @vereinsmitglieder = Statistics::Vereinsmitglieder.new

    respond_to do |format|
      format.html
      format.csv { send_data csv, type: :csv }
    end
  end

  private

  def csv
    Export::Tabular::Statistics::Vereinsmitglieder.csv(@vereinsmitglieder)
  end

  def group
    @group ||= Group::Dachverein.find(params[:id])
  end

  def authorize
    authorize!(:statistics, group)
  end
end
