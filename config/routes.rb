# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

Rails.application.routes.draw do

  extend LanguageRouteScope

  language_scope do

    resources :groups do
      member do
        scope 'time_record' do
          get ':year/edit' => 'time_records#edit', as: :edit_time_record
          put ':year' => 'time_records#update', as: :time_record
          get ':year' => 'time_records#edit' # route required for language switch
        end

        scope 'cost_accounting' do
          get '/' => 'cost_accounting#index', as: :cost_accounting
          get ':year/:report/edit' => 'cost_accounting#edit', as: :edit_cost_accounting_report
          put ':year/:report' => 'cost_accounting#update', as: :cost_accounting_report
          get ':year/:report' => 'cost_accounting#edit' # route required for language switch
        end

        get '/statistics' => 'statistics#show', as: :statistics
        get '/controlling' => 'controlling#index', as: :controlling
        get '/abo_addresses' => 'abo_addresses#index', as: :abo_addresses

      end

      resources :events, only: [] do # do not redefine events actions, only add new ones
        collection do
          get 'aggregate_course' => 'events#index', type: 'Event::AggregateCourse'

          scope 'general_cost_allocation' do
            get ':year/edit' => 'event/general_cost_allocations#edit',
                as: :edit_general_cost_allocation
            put ':year' => 'event/general_cost_allocations#update',
                as: :general_cost_allocation
            get ':year' => 'event/general_cost_allocations#edit' # route required for language switch
          end
        end

        scope module: 'event' do
          resource :course_record, only: [:edit, :update]
          get 'course_record' => 'course_records#edit' # route required for language switch
        end
      end
    end

    resources :reporting_parameters
  end

end
