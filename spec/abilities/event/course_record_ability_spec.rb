#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe Event::CourseRecordAbility do
  let(:user) { role.person }
  let(:group) { role.group }
  let(:event) {
    Fabricate(:course, groups: [group], leistungskategorie: "bk", fachkonzept: "sport_jugend")
  }
  let(:record) { Event::CourseRecord.new(event: event) }

  subject { Ability.new(user.reload) }

  context :layer_and_below_full do
    let(:role) do
      roles(:top_leader)
    end

    context Event::Course do
      it "may update report of event in his layer" do
        is_expected.to be_able_to(:update, record)
      end

      it "may update report of event in lower layer" do
        other = Event::CourseRecord.new(event: Fabricate(:course,
          groups: [groups(:seeland)],
          leistungskategorie: "bk", fachkonzept: "sport_jugend"))
        is_expected.to be_able_to(:update, other)
      end
    end
  end

  context :layer_full do
    let(:role) do
      Fabricate(Group::Regionalverein::Geschaeftsfuehrung.name.to_sym, group: groups(:be))
    end

    context Event::Course do
      it "may update report of event in his layer" do
        is_expected.to be_able_to(:update, record)
      end

      it "may not update report of event in lower layer" do
        other = Event::CourseRecord.new(event: Fabricate(:course,
          groups: [groups(:seeland)],
          leistungskategorie: "bk", fachkonzept: "sport_jugend"))
        is_expected.not_to be_able_to(:update, other)
      end

      context "in other layer" do
        let(:role) do
          Fabricate(Group::Regionalverein::Geschaeftsfuehrung.name.to_sym,
            group: groups(:fr))
        end

        it "may not update report of event" do
          other = Event::CourseRecord.new(event: Fabricate(:course,
            groups: [groups(:be)],
            leistungskategorie: "bk", fachkonzept: "sport_jugend"))
          is_expected.not_to be_able_to(:update, other)
        end
      end
    end
  end

  context :contact_data do
    let(:role) do
      Fabricate(Group::Regionalverein::Controlling.name.to_sym, group: groups(:be))
    end

    context Event::Course do
      it "may update report of event in his group" do
        is_expected.to be_able_to(:update, record)
      end

      it "may not update report of event in his layer" do
        other = Event::CourseRecord.new(event: Fabricate(:course,
          groups: [groups(:seeland)],
          leistungskategorie: "bk", fachkonzept: "sport_jugend"))
        is_expected.not_to be_able_to(:update, other)
      end

      it "may not update report of any other group" do
        other = Event::CourseRecord.new(event: Fabricate(:course,
          groups: [groups(:fr)],
          leistungskategorie: "bk", fachkonzept: "sport_jugend"))
        is_expected.not_to be_able_to(:update, other)
      end
    end
  end

  # The following scenarios are not testable with the insieme group structure, since there
  # is no role with permission :group_full in a group that allows Event::Course:
  #  * :group_full may update report of event in his group
  #  * :group_full may not update event in other group

  context :any do
    let(:role) do
      Fabricate(Group::Regionalverein::Controlling.name.to_sym, group: groups(:be))
    end

    context Event::Course do
      it "may update report of event he manages" do
        participation = Fabricate(:event_participation, event: event, participant: user)
        Event::Course::Role::LeaderAdmin.create!(participation: participation)
        is_expected.to be_able_to(:update, event)
      end

      it "may not update report of event he doesn't manage" do
        Fabricate(Event::Role::Participant.name.to_sym,
          participation: Fabricate(:event_participation,
            event: event, participant: user))

        is_expected.not_to be_able_to(:update, event)
      end
    end
  end
end
