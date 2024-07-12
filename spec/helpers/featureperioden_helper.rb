# frozen_string_literal: true

#  Copyright (c) 2023, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme

require "spec_helper"

describe FeatureperiodenHelper, type: :helper do
  context "#fp_t" do
    it "works" do
      allow(helper).to receive(:year).and_return(2023)
      allow(helper).to receive(:controller_name).and_return("time_records")

      expect(helper.fp_t("media")).to eq "Medien & Publikationen"
    end
  end
end
