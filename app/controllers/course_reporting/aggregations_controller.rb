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
    csv = Export::Tabular::CourseReporting::Aggregation.csv(aggregation)
    send_data csv, type: :csv, filename: filename
  end

  private

  def authorize
    authorize!(:reporting, group)
  end

  def aggregation
    @aggregation ||= CourseReporting::Aggregation.new(aggregation_group_id,
                                                      year,
                                                      leistungskategorie,
                                                      categories,
                                                      subsidized)
  end

  def aggregation_group_id
    if params[:consolidate] && can?(:controlling, group)
      nil
    else
      group.id
    end
  end

  def group
    @group ||= Group.find(params[:id])
  end

  def subsidized
    params[:subsidized].to_s.downcase == 'true'
  end

  def leistungskategorie
    params.fetch(:lk).downcase
  end

  def categories
    Array(params.fetch(:categories))
  end

  def filename
    subsi = subsidized ? 'subsidized' : 'unsubsidized'
    lk = t('activerecord.attributes.event/course.leistungskategorien.' +
           leistungskategorie, count: 3).downcase
    consolidated = aggregation_group_id.nil? ? '_consolidated' : ''
    "#{prefix}_#{year}_#{lk}_#{subsi}_#{categories.join('_')}#{consolidated}.csv"
  end

  def prefix
    vid = group.vid.present? && "_vid#{group.vid}" || ''
    bsv = group.bsv_number.present? && "_bsv#{group.bsv_number}" || ''
    "course_statistics#{vid}#{bsv}_#{group.name.parameterize}"
  end

end
