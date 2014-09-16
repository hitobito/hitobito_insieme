# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'


class ModulusValidationModel
  include ActiveModel::Validations
  validates :decimal_field, modulus: { multiple: 0.5 }
  validates :integer_field, modulus: { multiple: 2 }
  attr_accessor :decimal_field, :integer_field
end


describe ModulusValidator do

  subject(:model) { ModulusValidationModel.new }

  context 'decimal' do
    it 'should validate blank as valid' do
      allow(model).to receive(:decimal_field).and_return('')
      expect(model).to be_valid
    end

    it 'should validate 0.0 as valid' do
      allow(model).to receive(:decimal_field).and_return(BigDecimal.new('0.0'))
      expect(model).to be_valid
    end

    it 'should validate 0.5 as valid' do
      allow(model).to receive(:decimal_field).and_return(BigDecimal.new('0.5'))
      expect(model).to be_valid
    end

    it 'should validate 1.0 as valid' do
      allow(model).to receive(:decimal_field).and_return(BigDecimal.new('1.0'))
      expect(model).to be_valid
    end

    it 'should validate 0.25 as invalid' do
      allow(model).to receive(:decimal_field).and_return(BigDecimal.new('0.25'))
      expect(model).to_not be_valid
      expect(model).to have(1).error_on(:decimal_field)
    end
  end

  context 'integer' do
    it 'should validate blank as valid' do
      allow(model).to receive(:integer_field).and_return('')
      expect(model).to be_valid
    end

    it 'should validate 0 as valid' do
      allow(model).to receive(:integer_field).and_return(0)
      expect(model).to be_valid
    end

    it 'should validate 2 as valid' do
      allow(model).to receive(:integer_field).and_return(2)
      expect(model).to be_valid
    end

    it 'should validate 4 as valid' do
      allow(model).to receive(:integer_field).and_return(4)
      expect(model).to be_valid
    end

    it 'should validate 1 as invalid' do
      allow(model).to receive(:integer_field).and_return(1)
      expect(model).to_not be_valid
      expect(model).to have(1).error_on(:integer_field)
    end

    it 'should validate 3 as invalid' do
      allow(model).to receive(:integer_field).and_return(3)
      expect(model).to_not be_valid
      expect(model).to have(1).error_on(:integer_field)
    end
  end

end
