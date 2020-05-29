# == Schema Information
#
# Table name: event_course_records
#
#  id                               :integer          not null, primary key
#  event_id                         :integer          not null
#  inputkriterien                   :string(1)
#  subventioniert                   :boolean          default(TRUE), not null
#  kursart                          :string(255)
#  kursdauer                        :decimal(12, 2)
#  teilnehmende_behinderte          :integer
#  teilnehmende_angehoerige         :integer
#  teilnehmende_weitere             :integer
#  absenzen_behinderte              :decimal(12, 2)
#  absenzen_angehoerige             :decimal(12, 2)
#  absenzen_weitere                 :decimal(12, 2)
#  leiterinnen                      :integer
#  fachpersonen                     :integer
#  hilfspersonal_ohne_honorar       :integer
#  hilfspersonal_mit_honorar        :integer
#  kuechenpersonal                  :integer
#  honorare_inkl_sozialversicherung :decimal(12, 2)
#  unterkunft                       :decimal(12, 2)
#  uebriges                         :decimal(12, 2)
#  beitraege_teilnehmende           :decimal(12, 2)
#  spezielle_unterkunft             :boolean          default(FALSE), not null
#  year                             :integer
#  teilnehmende_mehrfachbehinderte  :integer
#  direkter_aufwand                 :decimal(12, 2)
#  gemeinkostenanteil               :decimal(12, 2)
#  gemeinkosten_updated_at          :datetime
#  zugeteilte_kategorie             :string(2)
#  challenged_canton_count_id       :integer
#  affiliated_canton_count_id       :integer
#  anzahl_kurse                     :integer          default(1)
#  tage_behinderte                  :decimal(12, 2)
#  tage_angehoerige                 :decimal(12, 2)
#  tage_weitere                     :decimal(12, 2)
#


#  Copyright (c) 2012-2019, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class Event::CourseRecordsController < CrudController

  include Vertragsperioden::Views

  decorates :event, :course_record

  authorize_resource except: :index, singleton: true

  self.nesting = Group, Event

  self.permitted_attrs = [:subventioniert,
                          :inputkriterien,
                          :kursart,
                          :spezielle_unterkunft,
                          :kursdauer,
                          :teilnehmende_mehrfachbehinderte,
                          :teilnehmende_weitere,
                          :absenzen_behinderte,
                          :absenzen_angehoerige,
                          :absenzen_weitere,
                          :tage_behinderte,
                          :tage_angehoerige,
                          :tage_weitere,
                          :leiterinnen,
                          :fachpersonen,
                          :hilfspersonal_ohne_honorar,
                          :hilfspersonal_mit_honorar,
                          :kuechenpersonal,
                          :betreuerinnen,
                          :honorare_inkl_sozialversicherung,
                          :unterkunft,
                          :uebriges,
                          :beitraege_teilnehmende,
                          :anzahl_kurse,
                          :year,
                          challenged_canton_count_attributes: Cantons::SHORT_NAMES,
                          affiliated_canton_count_attributes: Cantons::SHORT_NAMES]

  before_render_form :replace_decimal_with_integer, if: -> { entry.duration_in_hours? }
  before_render_form :set_numbers
  before_render_form :alert_missing_reporting_parameters
  before_render_form :build_canton_counts

  helper_method :year

  def self.model_class
    Event::CourseRecord
  end

  private

  def entry
    model_ivar_get || model_ivar_set(find_entry)
  end

  def find_entry
    not_found unless parent.reportable?
    parent.course_record || parent.build_course_record
  end

  def event_year
    parent.dates.first.start_at.year
  end

  def year
    entry.year_changed? ? entry.year_was : entry.year
  end

  def return_path
    edit_group_event_course_record_path(*parents)
  end

  # with mysql when saving value 1 it is rerenderd as 1.0 which is considered decimal
  def replace_decimal_with_integer
    [:kursdauer, :absenzen_behinderte, :absenzen_angehoerige, :absenzen_weitere,
     :tage_behinderte, :tage_angehoerige, :tage_weitere].each do |field|
      value = entry.send(field)
      entry.send("#{field}=", value.to_i) if value.to_i == value
    end
  end

  def set_numbers
    @numbers = CourseReporting::CourseNumbers.new(parent)
  end

  def alert_missing_reporting_parameters
    unless ReportingParameter.for(entry.year)
      flash.now[:alert] = t('event.course_records.form.missing_reporting_parameters')
    end
  end

  def build_canton_counts
    entry.challenged_canton_count || entry.build_challenged_canton_count
    entry.affiliated_canton_count || entry.build_affiliated_canton_count
  end
end
