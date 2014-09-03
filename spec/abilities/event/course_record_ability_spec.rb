# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Event::CourseRecordAbility do

  let(:user)    { role.person }
  let(:group)   { role.group }
  let(:event)   { Fabricate(:event, groups: [group]) }
  let(:record)  { Event::CourseRecord.new(event: event) }

  subject { Ability.new(user.reload) }

  context :layer_full do
    let(:role) do
      Fabricate(Group::Regionalverein::Geschaeftsfuehrung.name.to_sym, group: groups(:be))
    end

    context Event do
      it 'may update report of event in his group' do
        should be_able_to(:update, record)
      end

      it 'may update report of event in his layer' do
        should be_able_to(:update, record)
      end

      it 'may update report of event in lower layer' do
        other = Event::CourseRecord.new(event: Fabricate(:event, groups: [groups(:seeland)]))
        should be_able_to(:update, other)
      end

      context 'in other layer' do
        let(:role) do
          Fabricate(Group::Regionalverein::Geschaeftsfuehrung.name.to_sym,
                    group: groups(:fr))
        end

        it 'may not update report of event' do
          other = Event::CourseRecord.new(event: Fabricate(:event, groups: [groups(:be)]))
          should_not be_able_to(:update, other)
        end
      end
    end
  end

  context :group_full do
    let(:role) do
      Fabricate(Group::DachvereinGremium::Leitung.name.to_sym,
                group: groups(:kommission74))
    end

    context Event do
      it 'may update report of event in his group' do
        should be_able_to(:update, event)
      end

      it 'may not update event in other group' do
        other = Event::CourseRecord.new(event: Fabricate(:event, groups: [groups(:dachverein)]))
        should_not be_able_to(:update, other)
      end
    end
  end

  context :any do
    let(:role) do
      Fabricate(Group::Regionalverein::Controlling.name.to_sym, group: groups(:be))
    end

    context Event do
      it 'may update report of event he manages' do
        Fabricate(Event::Role::Leader.name.to_sym,
                  participation: Fabricate(:event_participation,
                                           event: event, person: user))
        should be_able_to(:update, event)
      end

      it 'may not update report of event he doesn\'t manage' do
        Fabricate(Event::Role::Participant.name.to_sym,
                  participation: Fabricate(:event_participation,
                                           event: event, person: user))

        should_not be_able_to(:update, event)
      end
    end
  end

end
