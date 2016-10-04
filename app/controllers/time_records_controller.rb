# encoding: utf-8
# == Schema Information
#
# Table name: time_records
#
#  id                                       :integer          not null, primary key
#  group_id                                 :integer          not null
#  year                                     :integer          not null
#  verwaltung                               :integer
#  beratung                                 :integer
#  treffpunkte                              :integer
#  blockkurse                               :integer
#  tageskurse                               :integer
#  jahreskurse                              :integer
#  kontakte_medien                          :integer
#  interviews                               :integer
#  publikationen                            :integer
#  referate                                 :integer
#  medienkonferenzen                        :integer
#  informationsveranstaltungen              :integer
#  sensibilisierungskampagnen               :integer
#  auskunftserteilung                       :integer
#  kontakte_meinungsbildner                 :integer
#  beratung_medien                          :integer
#  eigene_zeitschriften                     :integer
#  newsletter                               :integer
#  informationsbroschueren                  :integer
#  eigene_webseite                          :integer
#  erarbeitung_instrumente                  :integer
#  erarbeitung_grundlagen                   :integer
#  projekte                                 :integer
#  vernehmlassungen                         :integer
#  gremien                                  :integer
#  vermittlung_kontakte                     :integer
#  unterstuetzung_selbsthilfeorganisationen :integer
#  koordination_selbsthilfe                 :integer
#  treffen_meinungsaustausch                :integer
#  beratung_fachhilfeorganisationen         :integer
#  unterstuetzung_behindertenhilfe          :integer
#  mittelbeschaffung                        :integer
#  allgemeine_auskunftserteilung            :integer
#  type                                     :string(255)      not null
#  total_lufeb_general                      :integer
#  total_lufeb_private                      :integer
#  total_lufeb_specific                     :integer
#  total_lufeb_promoting                    :integer
#  nicht_art_74_leistungen                  :integer
#


#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class TimeRecordsController < ReportingBaseController

  TYPES = [TimeRecord::EmployeeTime,
           TimeRecord::VolunteerWithVerificationTime,
           TimeRecord::VolunteerWithoutVerificationTime]

  include Rememberable

  self.remember_params = [:year]

  before_action :entry, except: [:index, :exports]

  def index
    @table = TimeRecord::Table.new(group, year)

    respond_to do |format|
      format.html
      format.csv do
        send_data Export::Csv::TimeRecords::BaseInformation.export(@table), type: :csv
      end
    end
  end

  def exports
    year
  end

  private

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
    fields = TimeRecord.column_names - %w(id year group_id)
    if entry.is_a?(TimeRecord::EmployeeTime)
      fields += [employee_pensum_attributes: [:id, :paragraph_74, :not_paragraph_74]]
    end
    params.require(:time_record).permit(fields)
  end

  def show_path
    time_record_group_path(group, year: year)
  end

end
