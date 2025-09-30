module Policies
    module Fsio2428
         
        # Stop adding Grundlagenarbeit to export client_statistics for
        # the leistungskategorien  sk, bk and tk, but keep adding for tp.
        class V11
            def include_grundlagen_hours_for?(fachkonzept)
                fachkonzept == "treffpunkt"
        end
    end
end