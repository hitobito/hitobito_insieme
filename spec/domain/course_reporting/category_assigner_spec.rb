# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe CourseReporting::CategoryAssigner do

  let(:event) { events(:top_course) }
  let(:assigner) { CourseReporting::CategoryAssigner.new(record) }

  let(:year)           { nil }
  let(:inputkriterien) { 'a' }
  let(:kosten)         { nil }
  let(:tage)           { nil }
  let(:teilnehmende)   { nil }

  let(:record) do
    event.build_course_record(
      year: year,
      inputkriterien: inputkriterien,
      unterkunft: kosten,
      kursdauer: tage,
      total_tage_teilnehmende: teilnehmende && teilnehmende * tage)
  end


  subject { assigner.compute }

  context 'with empty course record' do
    context 'and without year' do

      it 'assigns category 1' do
        is_expected.to eq 1
      end
    end

    context 'and year with params' do
      let(:year) { 2015 }

      it 'assigns category 1' do
        is_expected.to eq 1
      end
    end

    context 'and year without params' do
      let(:year) { 2012 }

      it 'assigns category 1' do
        is_expected.to eq 1
      end
    end
  end

  context 'with bk course record' do
    let(:year) { 2014 }
    let(:kosten)         { nil }
    let(:tage)           { 10 }
    let(:teilnehmende)   { 10 }

    before { event.leistungskategorie = 'bk' }

    {
      { inputkriterien: 'a', kosten: 0 } => 1,
      { inputkriterien: 'a', kosten: 44200 } => 1,
      { inputkriterien: 'b', kosten: 64300 } => 1,
      { inputkriterien: 'a', kosten: 64301 } => 1,

      { inputkriterien: 'b', kosten: 0 } => 1,
      { inputkriterien: 'b', kosten: 44200 } => 2,
      { inputkriterien: 'b', kosten: 64300 } => 2,
      { inputkriterien: 'b', kosten: 64301 } => 2,

      { inputkriterien: 'c', kosten: 0 } => 1,
      { inputkriterien: 'c', kosten: 44200 } => 2,
      { inputkriterien: 'c', kosten: 64300 } => 2,
      { inputkriterien: 'c', kosten: 64301 } => 3,
    }.each do |attrs, category|
      context "with #{attrs.inspect}" do
        let(:inputkriterien) { attrs[:inputkriterien] }
        let(:kosten) { attrs[:kosten] }

        it { is_expected.to eq category }
      end
    end

    context 'without cost accounting params' do
      let(:year) { 2012 }

      {
        { inputkriterien: 'a', kosten: 0 } => 1,
        { inputkriterien: 'a', kosten: 64301 } => 1,

        { inputkriterien: 'b', kosten: 0 } => 1,
        { inputkriterien: 'b', kosten: 64301 } => 1,

        { inputkriterien: 'c', kosten: 0 } => 1,
        { inputkriterien: 'c', kosten: 64301 } => 1,
      }.each do |attrs, category|
        context "with #{attrs.inspect}" do
          let(:inputkriterien) { attrs[:inputkriterien] }
          let(:kosten) { attrs[:kosten] }

          it { is_expected.to eq category }
        end
      end
    end
  end

  context 'with tk course record' do
    let(:year) { 2014 }
    let(:kosten)         { nil }
    let(:tage)           { 10 }
    let(:teilnehmende)   { 10 }

    before { event.leistungskategorie = 'tk' }

    {
      { inputkriterien: 'a', kosten: 0 } => 1,
      { inputkriterien: 'a', kosten: 34100 } => 1,
      { inputkriterien: 'b', kosten: 47500 } => 1,
      { inputkriterien: 'a', kosten: 47501 } => 1,

      { inputkriterien: 'b', kosten: 0 } => 1,
      { inputkriterien: 'b', kosten: 34100 } => 2,
      { inputkriterien: 'b', kosten: 47500 } => 2,
      { inputkriterien: 'b', kosten: 47501 } => 2,

      { inputkriterien: 'c', kosten: 0 } => 1,
      { inputkriterien: 'c', kosten: 34100 } => 2,
      { inputkriterien: 'c', kosten: 47500 } => 2,
      { inputkriterien: 'c', kosten: 47501 } => 3,
    }.each do |attrs, category|
      context "with #{attrs.inspect}" do
        let(:inputkriterien) { attrs[:inputkriterien] }
        let(:kosten) { attrs[:kosten] }

        it { is_expected.to eq category }
      end
    end

    context 'without cost accounting params' do
      let(:year) { 2012 }

      {
        { inputkriterien: 'a', kosten: 0 } => 1,
        { inputkriterien: 'a', kosten: 64301 } => 1,

        { inputkriterien: 'b', kosten: 0 } => 1,
        { inputkriterien: 'b', kosten: 64301 } => 1,

        { inputkriterien: 'c', kosten: 0 } => 1,
        { inputkriterien: 'c', kosten: 64301 } => 1,
      }.each do |attrs, category|
        context "with #{attrs.inspect}" do
          let(:inputkriterien) { attrs[:inputkriterien] }
          let(:kosten) { attrs[:kosten] }

          it { is_expected.to eq category }
        end
      end
    end
  end

  context 'with sk course record' do
    let(:year) { 2014 }
    let(:kosten)         { nil }
    let(:tage)           { 10 }
    let(:teilnehmende)   { 10 }

    before { event.leistungskategorie = 'sk' }

    {
      { inputkriterien: 'a', kosten: 0 } => 1,
      { inputkriterien: 'a', kosten: 44200 } => 1,
      { inputkriterien: 'b', kosten: 64300 } => 1,
      { inputkriterien: 'a', kosten: 64301 } => 1,

      { inputkriterien: 'b', kosten: 0 } => 1,
      { inputkriterien: 'b', kosten: 44200 } => 1,
      { inputkriterien: 'b', kosten: 64300 } => 1,
      { inputkriterien: 'b', kosten: 64301 } => 1,

      { inputkriterien: 'c', kosten: 0 } => 1,
      { inputkriterien: 'c', kosten: 44200 } => 1,
      { inputkriterien: 'c', kosten: 64300 } => 1,
      { inputkriterien: 'c', kosten: 64301 } => 1,
    }.each do |attrs, category|
      context "with #{attrs.inspect}" do
        let(:inputkriterien) { attrs[:inputkriterien] }
        let(:kosten) { attrs[:kosten] }

        it { is_expected.to eq category }
      end
    end
  end
end
