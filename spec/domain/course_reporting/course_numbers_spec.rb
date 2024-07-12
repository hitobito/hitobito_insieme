#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe CourseReporting::CourseNumbers do
  let(:event) { events(:top_course) }

  subject { CourseReporting::CourseNumbers.new(event) }

  context "duration days" do
    it "is correct for half days" do
      expect(subject.duration_days).to eq(8.5)
    end
  end

  context "duration hours" do
    it "is correct for whole days" do
      expect(subject.duration_hours).to eq(7 * 24)
    end
  end

  context "role counts" do
    context "#challenged_count" do
      it "is correct" do
        expect(subject.challenged_count).to eq(1)
      end
    end

    context "#affiliated_count" do
      it "is correct" do
        expect(subject.affiliated_count).to eq(0)
      end

      it "is correct with duplicate roles" do
        Fabricate(Event::Course::Role::Affiliated.name.to_sym,
          participation: event_participations(:top_participant))
        expect(subject.affiliated_count).to eq(0)
      end
    end

    context "#participant_count" do
      before do
        Fabricate(Event::Course::Role::Affiliated.name.to_sym,
          participation: Fabricate(:event_participation, event: event))
      end

      it "is correct" do
        expect(subject.participant_count).to eq(2)
      end

      it "is correct with duplicate roles" do
        Fabricate(Event::Course::Role::Affiliated.name.to_sym,
          participation: event_participations(:top_participant))
        expect(subject.participant_count).to eq(2)
      end
    end

    context "#leader_count" do
      it "is correct" do
        expect(subject.leader_count).to eq(1)
      end
    end

    context "#expert_count" do
      before do
        Fabricate(Event::Course::Role::Expert.name.to_sym,
          participation: Fabricate(:event_participation, event: event))
      end

      it "is correct" do
        expect(subject.expert_count).to eq(1)
      end

      it "is correct with duplicate lower roles" do
        Fabricate(Event::Course::Role::Expert.name.to_sym,
          participation: event_participations(:top_participant))
        expect(subject.expert_count).to eq(2)
      end

      it "is correct with duplicate higher roles" do
        Fabricate(Event::Course::Role::Expert.name.to_sym,
          participation: event_participations(:top_leader))
        expect(subject.expert_count).to eq(1)
      end
    end

    context "#caretaker_count" do
      before do
        Fabricate(Event::Course::Role::Caretaker.name.to_sym,
          participation: event_participations(:top_participant))
      end

      it "is correct" do
        expect(subject.caretaker_count).to eq(1)
      end

      it "is correct with duplicate roles" do
        Fabricate(Event::Course::Role::Caretaker.name.to_sym,
          participation: event_participations(:top_participant))
        expect(subject.caretaker_count).to eq(1)
      end
    end

    context "#team_count" do
      before do
        Fabricate(Event::Course::Role::Caretaker.name.to_sym, participation: Fabricate(:event_participation, event: event))
        Fabricate(Event::Course::Role::Expert.name.to_sym, participation: Fabricate(:event_participation, event: event))
        Fabricate(Event::Course::Role::Affiliated.name.to_sym, participation: Fabricate(:event_participation, event: event))
      end

      it "is correct" do
        expect(subject.team_count).to eq(3) # 1 from fixtures, but affiliated is not counted
      end
    end

    context "#invoice_amount_sum" do
      it "is 0 for no participations" do
        expect(subject.invoice_amount_sum).to eq(0)
      end

      it "is sums all invoice_amounts" do
        [{invoice_amount: nil},
          {invoice_amount: 1},
          {invoice_amount: 2}].each do |attrs|
          event.participations.build(attrs)
        end

        expect(subject.invoice_amount_sum).to eq(BigDecimal("3"))
      end
    end

    context "canton counts" do
      def create_participant(role, canton)
        Fabricate(role.name.to_sym,
          participation: Fabricate(:event_participation,
            event: event,
            person: Fabricate(:person, canton: canton)))
      end

      [[:challenged_canton_counts,
        Event::Course::Role::Challenged,
        Event::Course::Role::Affiliated],
        [:affiliated_canton_counts,
          Event::Course::Role::Affiliated,
          Event::Course::Role::Challenged]].each do |assoc, role, other_role|
        context "##{assoc}" do
          it "should sum participants per canton" do
            event.participations.destroy_all

            create_participant(role, "be")
            create_participant(role, "be")
            create_participant(role, "zh")
            create_participant(role, nil)
            create_participant(role, "")
            create_participant(other_role, "be")

            expect(subject.send(assoc)).to eq("undefined" => 2,
              "be" => 2,
              "zh" => 1)
          end
        end
      end
    end
  end

  context "participation counts" do
    let(:participation) { event_participations(:top_participant) }

    before do
      participation.update!(multiple_disability: true)
      event_participations(:top_leader).update!(multiple_disability: true)
    end

    context "#challenged_multiple_count" do
      it "is correct" do
        expect(subject.challenged_multiple_count).to eq(1)
      end

      it "only counts active participations" do
        participation.update_column(:active, false)
        expect(subject.challenged_multiple_count).to eq(0)
      end
    end
  end
end
