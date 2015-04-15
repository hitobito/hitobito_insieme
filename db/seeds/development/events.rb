# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require Rails.root.join('db', 'seeds', 'support', 'event_seeder')

srand(42)

class InsiemeEventSeeder < EventSeeder

  def course_attributes(values)
    attrs = super(values)
    attrs[:leistungskategorie] = Event::Reportable::LEISTUNGSKATEGORIEN.shuffle.first
    attrs
  end

  def seed_course(values)
    seed_course_record(super(values))
  end

  def seed_course_record(event)
    Event::CourseRecord.seed(:event_id, event_id: event.id).first
  end
end


seeder = InsiemeEventSeeder.new

layer_types = Group.all_types.select(&:layer).collect(&:sti_name)
Group.where(type: layer_types).pluck(:id).each do |group_id|
  5.times do
    seeder.seed_event(group_id, :base)
    seeder.seed_event(group_id, :course)
  end
end
