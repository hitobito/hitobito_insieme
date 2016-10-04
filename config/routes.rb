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
          get '/' => 'time_records#index', as: :time_record
          get ':year/base_information' => 'time_record/base_informations#index',
              as: :time_record_base_information
          get ':year/exports' => 'time_records#exports', as: :time_record_exports
          get ':year/:report/edit' => 'time_records#edit', as: :edit_time_record_report
          put ':year/:report' => 'time_records#update', as: :time_record_report
          get ':year/:report' => 'time_records#edit' # route required for language switch
        end

        scope 'cost_accounting' do
          get '/' => 'cost_accounting#index', as: :cost_accounting
          get ':year/:report/edit' => 'cost_accounting#edit', as: :edit_cost_accounting_report
          put ':year/:report' => 'cost_accounting#update', as: :cost_accounting_report
          get ':year/:report' => 'cost_accounting#edit' # route required for language switch
        end

        scope 'capital_substrate' do
          get ':year/edit' => 'capital_substrate#edit', as: :edit_capital_substrate
          put ':year' => 'capital_substrate#update', as: :capital_substrate
          get ':year' => 'capital_substrate#edit' # route required for language switch
        end

        get '/statistics' => 'statistics#index', as: :statistics
        get '/controlling' => 'controlling#index', as: :controlling
        get '/controlling/cost_accounting' => 'controlling#cost_accounting',
            as: :cost_accounting_controlling
        get '/controlling/client_statistics' => 'controlling#client_statistics',
            as: :client_statistics_controlling
        get '/controlling/group_figures' => 'controlling#group_figures',
            as: :group_figures_controlling
        get '/abo_addresses' => 'abo_addresses#index', as: :abo_addresses

        scope module: 'course_reporting' do
          get ':year/aggregations' => 'aggregations#index', as: :aggregations
          get ':year/aggregation/export' => 'aggregations#export', as: :aggregation_export
        end
      end

      resources :events, only: [] do # do not redefine events actions, only add new ones
        collection do
          get 'aggregate_course' => 'events#index', type: 'Event::AggregateCourse'

          scope 'general_cost_allocation' do
            get ':year' => 'event/general_cost_allocations#show', as: :general_cost_allocation
            get ':year/edit' => 'event/general_cost_allocations#edit',
                as: :edit_general_cost_allocation
            put ':year' => 'event/general_cost_allocations#update'
          end
        end

        scope module: 'event' do
          resource :course_record, only: [:edit, :update]
          get 'course_record' => 'course_records#edit' # route required for language switch
        end
      end
    end

    resource :global_value, only: [:show, :edit, :update]

    resources :reporting_parameters, except: :show

  end

end
