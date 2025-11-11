# frozen_string_literal: true

module Fp2024
  module Export
    module Tabular
      module CourseReporting
        class ClientStatistics < Fp2022::Export::Tabular::CourseReporting::ClientStatistics
          private

          # Policy is computed from the year exposed by the fp2022 base (delegates :year to stats)
          def policy
            @policy ||= PolicyRegistry.for(year: year)
          end

          # Only change: if the policy says "exclude grundlagen_hours", return just the course_hours.
          # Otherwise, fall back to the fp2022 behavior (which adds grundlagen_hours).
          def course_hours_including_grundlagen_hours(gcp)
            return super if policy.include_grundlagen_hours?
            maybe_zero(gcp.course_hours.to_f)
          end
        end
      end
    end
  end
end
