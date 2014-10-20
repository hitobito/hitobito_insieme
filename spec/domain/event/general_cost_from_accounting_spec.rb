# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Event::GeneralCostFromAccounting do

  let(:group) { groups(:be) }

  subject { Event::GeneralCostFromAccounting.new(group, 2014) }

  context 'without values' do
    it 'is zero for tageskurse' do
      subject.general_cost('tk').should eq 0
    end

    it 'is zero for blockkurse' do
      subject.general_cost('bk').should eq 0
    end

    it 'is zero for jahreskurse' do
      subject.general_cost('sk').should eq 0
    end

    it 'fails for other input' do
      expect { subject.general_cost('foo') }.to raise_error(KeyError)
    end
  end

  context 'with values' do

    before do
      create_report('lohnaufwand', aufwand_ertrag_fibu: 100)
      create_report('sozialversicherungsaufwand', aufwand_ertrag_fibu: 200)
      create_report('uebriger_personalaufwand', aufwand_ertrag_fibu: 300)
      create_report('honorare', aufwand_ertrag_fibu: 400)
      create_report('raumaufwand', raeumlichkeiten: 100)

      create_time_record(verwaltung: 50, beratung: 30, tageskurse: 10, blockkurse: 40)
    end

    it 'is correct for tageskurse' do
      subject.general_cost('tk').should eq 87.5
    end

    it 'is correct blockkurse' do
      subject.general_cost('bk').should eq 350
    end

    it 'is correct for jahreskurse' do
      subject.general_cost('sk').should eq 0
    end
  end

  def create_time_record(values)
    TimeRecord.create!(values.merge(group_id: group.id,
                                    year: 2014))
  end

  def create_report(name, values)
    CostAccountingRecord.create!(values.merge(group_id: group.id,
                                              year: 2014,
                                              report: name))
  end

end
