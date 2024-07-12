# frozen_string_literal: true

#  Copyright (c) 2012-2021, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class ControllingController < ApplicationController
  include YearBasedPaging
  include Featureperioden::Views
  include Featureperioden::Domain

  respond_to :html

  decorates :group

  helper_method :group

  before_action :authorize

  def index
    year
  end

  # Konsolidierte Kostenrechnung
  def cost_accounting
    @table = fp_class("CostAccounting::Aggregation").new(year)
    xlsx = fp_class("Export::Tabular::CostAccounting::List")
      .xlsx(@table.reports.values, group.name, year)
    send_data xlsx, type: :xlsx, filename: "cost_accounting_#{year}.xlsx"
  end

  # Kostenrechnung pro Verein
  def pro_verein
    @list = fp_class("CostAccounting::ProVerein").new(year)
    csv = fp_class("Export::Tabular::CostAccounting::ProVerein").csv(@list)
    send_data csv, type: :csv, filename: "cost_accounting_pro_verein_#{year}.csv"
  end

  # KlientInnen Statistik
  def client_statistics
    @stats = fp_class("CourseReporting::ClientStatistics").new(year)
    csv = fp_class("Export::Tabular::CourseReporting::ClientStatistics").csv(@stats)
    send_data csv, type: :csv, filename: "client_statistics_#{year}.csv"
  end

  # Kennzahlen pro Verein
  def group_figures
    @stats = fp_class("Statistics::GroupFigures").new(year)
    csv = fp_class("Export::Tabular::Statistics::GroupFigures").csv(@stats)
    send_data csv, type: :csv, filename: "group_figures_#{year}.csv"
  end

  # Zusammenzug Zeiterfassungen
  # - Angestellte
  # - Ehrenamtliche mit Leistungsnachweis
  # - Ehrenamtliche ohne Leistungsnachweis
  def time_records
    @list = fp_class("TimeRecord::Vereinsliste").new(year, params[:type])
    csv = fp_class("Export::Tabular::TimeRecords::Vereinsliste").csv(@list)
    filename = "#{params[:type].to_s.underscore.tr("/", "_")}_#{year}.csv"
    send_data csv, type: :csv, filename: filename
  end

  # LUFEB pro Verein
  def lufeb_times
    @list = fp_class("TimeRecord::LufebProVerein").new(year)
    csv = fp_class("Export::Tabular::TimeRecords::LufebProVerein").csv(@list)
    send_data csv, type: :csv, filename: "lufeb_pro_verein_#{year}.csv"
  end

  # Organisationsdaten pro Verein
  def group_data
    @list = fp_class("TimeRecord::OrganisationsDaten").new(year)
    csv = fp_class("Export::Tabular::TimeRecords::OrganisationsDaten").csv(@list)
    send_data csv, type: :csv, filename: "organisationsdaten_pro_verein_#{year}.csv"
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
