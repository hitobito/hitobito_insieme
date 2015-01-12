# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class AboAddressesController < ApplicationController

  before_action :authorize

  def index
    send_data csv, type: :csv
  end

  private

  def csv
    Export::Csv::AboAddresses::List.export(people)
  end

  def people
    AboAddresses::Query.new(params[:country] == 'ch', params[:language]).people
  end

  def group
    @group ||= Group::Dachverein.find(params[:id])
  end

  def authorize
    authorize!(:index_deep_full_people, group)
  end
end
