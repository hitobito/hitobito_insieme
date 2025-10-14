#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe EventAbility do
  let(:event) { events(:top_course) }
  let(:role) { create_role }
  let(:ability) { Ability.new(role.person.reload) }

  def create_role(event_role_type = role_type)
    participation = Fabricate(:event_participation, person: Fabricate(:person), event: event)
    event_role_type.create!(participation: participation)
  end

  class << self
    def may_execute(*actions)
      may_or_not(actions, "may", :to)
    end

    def may_not_execute(*actions)
      may_or_not(actions, "may not", :not_to)
    end

    def may_or_not(actions, text, method)
      actions.each do |action|
        it "#{text} execute #{action}" do
          expect(ability).send(method, be_able_to(action, model))
        end
      end
    end
  end

  context :read do
    subject { ability }

    context "layer read and below" do
      let(:role) {
        Fabricate(Group::Dachverein::Geschaeftsfuehrung.name.to_sym,
          group: groups(:dachverein))
      }

      context "regular event" do
        context "in same layer" do
          it { is_expected.to be_able_to(:read, Fabricate.build(:event, groups: [role.group])) }

          it { is_expected.to be_able_to(:update, Fabricate.build(:event, groups: [role.group])) }

          it { is_expected.to be_able_to(:destroy, Fabricate.build(:event, groups: [role.group])) }

          context "with reporting frozen" do
            before { GlobalValue.first.update!(reporting_frozen_until_year: 2015) }
            after { GlobalValue.clear_cache }

            it { is_expected.to be_able_to(:read, Fabricate.build(:event, groups: [role.group])) }

            it { is_expected.to be_able_to(:update, Fabricate.build(:event, groups: [role.group])) }

            it {
              is_expected.to be_able_to(:destroy, Fabricate.build(:event, groups: [role.group]))
            }
          end
        end

        context "in lower layer" do
          it {
            is_expected.to be_able_to(:read, Fabricate.build(:event, groups: [groups(:seeland)]))
          }
        end
      end

      context "aggregate course" do
        let(:year) { 2016 }

        before do
          @course = Fabricate(:aggregate_course,
            groups: [role.group],
            year: year,
            leistungskategorie: "bk", fachkonzept: "sport_jugend",
            course_record_attributes: {year: year})
        end

        context "in same layer" do
          it { is_expected.to be_able_to(:read, @course) }

          it { is_expected.to be_able_to(:update, @course) }

          it { is_expected.to be_able_to(:destroy, @course) }

          context "with reporting frozen" do
            before { GlobalValue.first.update!(reporting_frozen_until_year: 2015) }
            after { GlobalValue.clear_cache }

            context "later" do
              let(:year) { 2016 }

              it { is_expected.to be_able_to(:update, @course) }

              it { is_expected.to be_able_to(:destroy, @course) }
            end

            context "before" do
              let(:year) { 2015 }

              it { is_expected.to be_able_to(:read, @course) }

              it { is_expected.not_to be_able_to(:update, @course) }

              it { is_expected.not_to be_able_to(:destroy, @course) }
            end
          end
        end

        context "in lower layer" do
          it {
            is_expected.to be_able_to(:read,
              Fabricate.build(:aggregate_course, groups: [groups(:seeland)]))
          }
        end
      end
    end

    context "any role" do
      let(:role) { Fabricate(Group::Regionalverein::Praesident.name.to_sym, group: groups(:be)) }

      context "regular event" do
        context "in same layer" do
          it { is_expected.to be_able_to(:read, Fabricate.build(:event, groups: [role.group])) }
        end

        context "in upper layer" do
          it {
            is_expected.not_to be_able_to(:read,
              Fabricate.build(:event, groups: [groups(:dachverein)]))
          }
        end

        context "in lower non-regionalverein layer" do
          it {
            is_expected.not_to be_able_to(:read, Fabricate.build(:event, groups: [groups(:aktiv)]))
          }
        end

        context "in lower regionalverein layer" do
          it {
            is_expected.to be_able_to(:read, Fabricate.build(:event, groups: [groups(:seeland)]))
          }
        end

        context "in other regionalverein layer" do
          it { is_expected.to be_able_to(:read, Fabricate.build(:event, groups: [groups(:fr)])) }
        end
      end

      context "aggregate course" do
        context "in same layer" do
          it {
            is_expected.to be_able_to(:read,
              Fabricate.build(:aggregate_course, groups: [role.group]))
          }
        end

        context "in upper layer" do
          it {
            is_expected.not_to be_able_to(:read,
              Fabricate.build(:aggregate_course, groups: [groups(:dachverein)]))
          }
        end

        context "in lower non-regionalverein layer" do
          it {
            is_expected.not_to be_able_to(:read,
              Fabricate.build(:aggregate_course, groups: [groups(:aktiv)]))
          }
        end

        context "in lower regionalverein layer" do
          it {
            is_expected.not_to be_able_to(:read,
              Fabricate.build(:aggregate_course, groups: [groups(:seeland)]))
          }
        end

        context "in other regionalverein layer" do
          it {
            is_expected.not_to be_able_to(:read,
              Fabricate.build(:aggregate_course, groups: [groups(:fr)]))
          }
        end
      end

      context "participating event" do
        let(:event) { Fabricate(:event, groups: [groups(:seeland)]) }

        before do
          Fabricate(Event::Role::Participant.name.to_sym,
            participation: Fabricate(:event_participation,
              event: event, person: role.person))
        end

        it { is_expected.to be_able_to(:read, event) }
      end
    end
  end

  [Event::Course::Role::LeaderBasic,
    Event::Course::Role::Expert,
    Event::Course::Role::HelperPaid,
    Event::Course::Role::HelperUnpaid].each do |leader_type|
  end

  [Event::Course::Role::Affiliated,
    Event::Course::Role::Challenged,
    Event::Course::Role::NotEntitledForBenefit].each do |participant_type|
  end
end
