# encoding: utf-8

#  Copyright (c) 2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class CourseReporting::AggregationsController < ApplicationController
  include YearBasedPaging
  layout 'reporting'
  before_action :authorize

  respond_to :html

  decorates :group

  helper_method :group

  def index
    year
  end

  def export
    csv = Export::Csv::CourseReporting::Aggregation.export(aggregation)
    send_data csv, type: :csv, filename: filename
  end

  private

  def authorize
    authorize!(:reporting, group)
  end

  def aggregation
    @aggregation ||= CourseReporting::Aggregation.new(group.id,
                                                      year,
                                                      params.fetch(:lk),
                                                      categories,
                                                      params.fetch(:subsidized))
  end

  def group
    @group ||= Group.find(params[:id])
  end

  def categories
    Array(params.fetch(:categories))
  end

  def filename
    subsidized = params[:subsidized] ? :subsidized : :unsubsidized
    lk = t("activerecord.attributes.event/course.leistungskategorien.#{params[:lk]}", count: 3)
    "course_statistics_#{group.id}_#{year}_#{lk.downcase}_#{subsidized}_#{categories.join('_')}.csv"
  end

end
