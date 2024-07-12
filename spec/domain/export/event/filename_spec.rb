require "spec_helper"

describe Export::Event::Filename do
  let(:year) { 2019 }
  let(:type) { nil }
  let(:group) { Group.new(name: :dummy) }

  subject { Export::Event::Filename.new(group, type, year) }

  it "joins simple prefix, group name and year" do
    expect(subject.to_s).to eq "simple_dummy_2019"
  end

  it "prepends bsv_number" do
    group.bsv_number = 1
    expect(subject.to_s).to eq "simple_bsv1_dummy_2019"
  end

  it "prepends vid" do
    group.vid = 1
    expect(subject.to_s).to eq "simple_vid1_dummy_2019"
  end

  it "prepends both vid and bsv" do
    group.bsv_number = 1
    group.vid = 2
    expect(subject.to_s).to eq "simple_vid2_bsv1_dummy_2019"
  end

  context :with_type do
    let(:type) { Event::Course }

    it "prepends type" do
      expect(subject.to_s).to eq "course_dummy_2019"
    end
  end
end
