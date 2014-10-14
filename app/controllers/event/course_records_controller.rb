# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class Event::CourseRecordsController < CrudController

  decorates :event, :course_record

  authorize_resource except: :index, singleton: true

  self.nesting = Group, Event

  self.permitted_attrs = [:subventioniert,
                          :inputkriterien,
                          :kursart,
                          :spezielle_unterkunft,
                          :kursdauer,
                          :teilnehmende_behinderte,
                          :teilnehmende_angehoerige,
                          :teilnehmende_weitere,
                          :absenzen_behinderte,
                          :absenzen_angehoerige,
                          :absenzen_weitere,
                          :leiterinnen,
                          :fachpersonen,
                          :hilfspersonal_ohne_honorar,
                          :hilfspersonal_mit_honorar,
                          :kuechenpersonal,
                          :honorare_inkl_sozialversicherung,
                          :unterkunft,
                          :uebriges,
                          :beitraege_teilnehmende
                         ]

  before_render_form :set_defaults, if: -> { entry.new_record? }
  before_render_form :replace_decimal_with_integer, if: -> { entry.sk? }
  before_render_form :set_numbers
  before_render_form :alert_missing_cost_accounting_parameters

  private

  def set_defaults
    entry.set_defaults
  end

  def entry
    model_ivar_get || model_ivar_set(find_entry)
  end

  def find_entry
    not_found unless parent.is_a?(Event::Course)
    parent.course_record || parent.build_course_record
  end

  def return_path
    edit_group_event_course_record_path(*parents)
  end

  def self.model_class
    Event::CourseRecord
  end

  # with mysql when saving value 1 it is rerenderd as 1.0 which is considered decimal
  def replace_decimal_with_integer
    [:kursdauer, :absenzen_behinderte, :absenzen_angehoerige, :absenzen_weitere] .each do |field|
      value = entry.send(field)
      entry.send("#{field}=", value.to_i) if value.to_i == value
    end
  end

  def set_numbers
    @numbers = CourseReporting::CourseNumbers.new(parent)
  end

  def alert_missing_cost_accounting_parameters
    unless CostAccountingParameter.for(entry.year)
      flash.now[:alert] = t('event.course_records.form.missing_cost_accounting_parameters')
    end
  end
end
