#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe MailingListAbility do
  let(:ability) { Ability.new(role.person.reload) }

  context :read do
    subject { ability }

    context "layer read and below" do
      let(:role) {
        Fabricate(Group::Dachverein::BerechtigungAdmin.sti_name, group: groups(:dachverein))
      }

      context "in same layer" do
        it { is_expected.to be_able_to(:show, Fabricate.build(:mailing_list, group: role.group)) }
      end

      context "in lower layer" do
        it {
          is_expected.to be_able_to(:show, Fabricate.build(:mailing_list, group: groups(:seeland)))
        }
      end
    end

    context "any role" do
      let(:role) {
        Fabricate(Group::Regionalverein::BerechtigungSekretariat.sti_name, group: groups(:be))
      }

      context "in same layer" do
        it { is_expected.to be_able_to(:show, Fabricate.build(:mailing_list, group: role.group)) }
      end

      context "in upper layer" do
        it {
          is_expected.not_to be_able_to(:show,
            Fabricate.build(:mailing_list, group: groups(:dachverein)))
        }
      end

      context "in lower layer" do
        it {
          is_expected.not_to be_able_to(:show,
            Fabricate.build(:mailing_list, group: groups(:seeland)))
        }
      end
    end
  end
end
