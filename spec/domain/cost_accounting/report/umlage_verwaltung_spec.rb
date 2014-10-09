require 'spec_helper'

describe CostAccounting::Report::UmlageVerwaltung do

  let(:year) { 2014 }
  let(:group) { groups(:be) }
  let(:table) { CostAccounting::Table.new(group, year) }
  let(:report) { table.reports.fetch('umlage_verwaltung') }
  let(:fields) { CostAccounting::Report::UmlageVerwaltung::FIELDS }



  context 'verwaltung is zero' do

    before do
      create_report('raumaufwand', raeumlichkeiten: 100)
      create_report('honorare', verwaltung: 0, beratung: 30, tageskurse: 10)
    end

    it 'defaults to nil' do
      CostAccountingRecord.find_by(report: 'raumaufwand').
        update_column(:raeumlichkeiten, nil)

      fields.each do |field|
        report.send(field.to_sym).should be_nil
      end
    end

    it 'total equals value of verwaltung' do
      report.total.should eq 0
    end

    it 'kontrolle is zero' do
      report.kontrolle.should eq 0
    end

  end

  context 'verwaltung is given' do

    before do
      create_report('raumaufwand', raeumlichkeiten: 100)
      create_report('honorare', verwaltung: 10, beratung: 30, tageskurse: 10)
    end

    it 'verwaltung is correct' do
      report.verwaltung.should eq(30)
    end

    context 'without time record' do
      it 'allocates verwaltung proportionally' do
        report.beratung.should eq 22.5
        report.tageskurse.should eq 7.5
      end

      it 'total equals value of verwaltung' do
        report.total.should eq 30
      end

      it 'kontrolle is zero' do
        report.kontrolle.should eq 0
      end

      it 'leaves other values at 0' do
        (fields - %w(beratung tageskurse)).each do |field|
          report.send(field.to_sym).should eq 0
        end
      end
    end

    context 'with time record' do

      it 'calculates values' do
        create_time_record(verwaltung: 50, beratung: 30, tageskurse: 20)

        report.verwaltung.should eq(60)
        report.beratung.should eq(36)
        report.tageskurse.should eq(24)
        report.total.should eq(60)
        report.kontrolle.should eq(0)

        (fields - %w(verwaltung beratung tageskurse)).each do |field|
          report.send(field.to_sym).should eq 0.0
        end
      end

      it 'calculates nil value for empty field of time_record' do
        create_time_record(verwaltung: 50)
        report.verwaltung.should eq 110
        report.beratung.should be_nil
      end
    end
  end

  def create_time_record(values)
    TimeRecord.create!(values.merge(group_id: group.id,
                                    year: year))
  end

  def create_report(name, values)
    CostAccountingRecord.create!(values.merge(group_id: group.id,
                                              year: year,
                                              report: name))
  end
end
