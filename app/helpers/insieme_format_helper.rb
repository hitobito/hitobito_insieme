# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module InsiemeFormatHelper

  def format_money(value)
    if value
      fnumber(value) + ' ' + t('global.currency')
    else
      ''
    end
  end

  def format_percent(value)
    if value
      fnumber(value) + ' %'
    else
      ''
    end
  end

  def format_hours(value)
    if value
      fnumber(value) + ' ' + t('global.hours_short')
    else
      ''
    end
  end

end
