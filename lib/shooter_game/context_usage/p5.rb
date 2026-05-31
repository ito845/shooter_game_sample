require "p5"

module ShooterGame
    module ContextUsage
        module P5
            def init_p5
                self[:p5] = ::P5.new
            end

            def p5
                self[:p5]
            end
        end
    end
end
