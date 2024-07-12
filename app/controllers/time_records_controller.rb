# frozen_string_literal: true

#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class TimeRecordsController < ReportingBaseController
  TYPES = [TimeRecord::EmployeeTime,
    TimeRecord::VolunteerWithVerificationTime,
    TimeRecord::VolunteerWithoutVerificationTime].freeze

  include Rememberable
  include Featureperioden::Views
  include Featureperioden::Domain

  self.remember_params = [:year]

  before_action :entry, except: [:index]

  def index
    respond_to do |format|
      format.html { redirect_to show_path }
      format.csv do
        send_data fp_class("Export::Tabular::TimeRecords::List")
          .csv(list_entries), type: :csv
      end
    end
  end

  private

  def list_entries
    TimeRecord.where(group_id: group.id, year: year)
  end

  def entry
    @record ||= record_class.where(group_id: group.id, year: year).first_or_initialize
    if @record.is_a?(TimeRecord::EmployeeTime) && @record.employee_pensum.nil?
      @record.build_employee_pensum
    end
    @record
  end

  def record_class
    TYPES.find { |t| t.name.demodulize.underscore == params[:report] } || not_found
  end

  def permitted_params
    fields = TimeRecord.column_names - %w[id year group_id]
    if entry.is_a?(TimeRecord::EmployeeTime)
      fields += [employee_pensum_attributes: [:id, :paragraph_74, :not_paragraph_74]]
    end
    params.require(:time_record).permit(fields)
  end

  def show_path
    if params["report"].present?
      time_record_report_group_path(group, year: year, report: params["report"])
    else
      time_record_base_information_group_path(group, year: year)
    end
  end
end
