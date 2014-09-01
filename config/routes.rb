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
        end

        scope 'cost_accounting' do
          get '(:year)' => 'cost_accounting#index', as: :cost_accounting
          get ':year/:report/edit' => 'cost_accounting#edit', as: :edit_cost_accounting_report
          put ':year/:report' => 'cost_accounting#update', as: :cost_accounting_report
        end
      end
    end
  end

end
