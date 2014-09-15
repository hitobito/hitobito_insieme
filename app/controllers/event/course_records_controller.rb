# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class Event::CourseRecordsController < CrudController

  decorates :event

  authorize_resource except: :index, singleton: true

  self.nesting = Group, Event

  self.permitted_attrs = [:inputkriterien,
                          :subventioniert,
                          :kursart,
                          :kurstage,
                          :teilnehmende_behinderte,
                          :teilnehmende_angehoerige,
                          :teilnehmende_weitere,
                          :absenztage_behinderte,
                          :absenztage_angehoerige,
                          :absenztage_weitere,
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


  private

  def entry
    model_ivar_get || model_ivar_set(find_entry)
  end

  def find_entry
    Event::CourseRecord.where(event_id: parent.id).first_or_initialize
  end

  def return_path
    edit_group_event_course_record_path(*parents)
  end

  def self.model_class
    Event::CourseRecord
  end
end
