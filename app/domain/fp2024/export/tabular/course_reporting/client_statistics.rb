# frozen_string_literal: true

module Fp2024
  module Export
    module Tabular
      module CourseReporting
        class ClientStatistics < Fp2022::Export::Tabular::CourseReporting::ClientStatistics
          # Policy is computed from the year exposed by the fp2022 base (delegates :year to stats)
          def policy
            @policy ||= PolicyRegistry.for(year: year)
          end

          def data_rows(_format = :csv)
            return enum_for(:data_rows) unless block_given?

            # prepend a stamp row
            yield empty_row
            yield ["Reporting-Jahr:", year]
            yield ["Policy:", policy.class.label]
            yield ["Druck:", Time.zone.now.strftime("%d.%m.%Y %H:%M")]
            yield empty_row

            # then call super to yield the normal rows
            super
          end

          private

          # If the policy says "exclude grundlagen_hours for Kurse", return just the course_hours
          # for the leistungskategorien sk, bk, tk, but still include grundlagen_hours for tp.
          # Otherwise, fall back to the fp2022 behavior (which adds grundlagen_hours for all leistungskategorien).
          def course_hours_including_grundlagen_hours(gcp)
            return super if policy.include_grundlagen_hours_for?(gcp.fachkonzept)
            maybe_zero(gcp.course_hours.to_f)
          end
        end
      end
    end
  end
end
