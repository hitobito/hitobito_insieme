require 'spec_helper'

describe CostAccounting::Report::UmlageRaeumlichkeiten do

  let(:year) { 2014 }
  let(:group) { groups(:be) }
  let(:table) { CostAccounting::Table.new(group, year) }
  let(:report) { table.reports.fetch('umlage_raeumlichkeiten') }
  let(:fields) { CostAccounting::Report::UmlageRaeumlichkeiten::FIELDS }


  before do
    create_report('raumaufwand', raeumlichkeiten: 100)
    create_report('honorare', verwaltung: 10, beratung: 30)
  end

  it 'defaults to nil if raumaufwand.raeumlichkeiten is nil' do
    CostAccountingRecord.find_by(report: 'raumaufwand').
      update_column(:raeumlichkeiten, nil)

    fields.each do |field|
      report.send(field.to_sym).should be_nil
    end
  end


  context 'without time record' do
    it 'allocates raeumlichkeiten proportionally' do
      report.verwaltung.should eq 25
      report.beratung.should eq 75
    end

    it 'total equals value of raeumlichkeiten' do
      report.total.should eq 100
    end

    it 'leaves other values at 0' do
      (fields - %w(verwaltung beratung total)).each do |field|
        report.send(field.to_sym).should eq 0
      end
    end
  end

  context 'with time record' do
    it 'calculates values' do
      create_time_record(verwaltung: 50, beratung: 30, blockkurse: 20)

      report.verwaltung.should eq(50)
      report.beratung.should eq(30)
      report.blockkurse.should eq(20)
      report.total.should eq(100)

      (fields - %w(verwaltung beratung blockkurse total)).each do |field|
        report.send(field.to_sym).should eq 0.0
      end
    end

    it 'calculates verwaltung if only verwaltung is set' do
      create_time_record(verwaltung: 50)
      report.verwaltung.to_f.should eq 100.0
      report.beratung.to_f.should eq 0.0
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
