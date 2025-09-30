module Policies
    module Fsio2428
         
        # Stop adding Grundlagenarbeit to export client_statistics
        class V11
            def include_grundlagen_hours? = false
        end
    end
end