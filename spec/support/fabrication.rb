# encoding: utf-8

#  Copyright (c) 2012-2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

Fabrication.configure do |config|
  config.fabricator_path = ['spec/fabricators', '../hitobito_insieme/spec/fabricators']
  config.path_prefix = Rails.root
end
