# encoding: utf-8

#  Copyright (c) 2012-2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class ControllingController < ApplicationController

  include YearBasedPaging
  include Vertragsperioden::Views
  include Vertragsperioden::Domain

  respond_to :html

  decorates :group

  helper_method :group

  before_action :authorize

  def index
    year
  end

  def cost_accounting
    @table = CostAccounting::Aggregation.new(year)
    xlsx = Export::Tabular::CostAccounting::List.xlsx(@table.reports.values, group.name, year)
    send_data xlsx, type: :xlsx, filename: "cost_accounting_#{year}.xlsx"
  end

  def client_statistics
    @stats = CourseReporting::ClientStatistics.new(year)
    csv = Export::Tabular::CourseReporting::ClientStatistics.csv(@stats)
    send_data csv, type: :csv, filename: "client_statistics_#{year}.csv"
  end

  def group_figures
    @stats = Statistics::GroupFigures.new(year)
    csv = Export::Tabular::Statistics::GroupFigures.csv(@stats)
    send_data csv, type: :csv, filename: "group_figures_#{year}.csv"
  end

  def time_records
    @list = vp_module('TimeRecord::Vereinsliste').new(year, params[:type])
    csv = Export::Tabular::TimeRecords::Vereinsliste.csv(@list)
    filename = "#{params[:type].to_s.underscore.tr('/', '_')}_#{year}.csv"
    send_data csv, type: :csv, filename: filename
  end

  private

  def group
    @group ||= Group::Dachverein.find(params[:id])
  end

  def default_year
    @default_year ||= GlobalValue.default_reporting_year
  end

  def authorize
    authorize!(:controlling, group)
  end

end
