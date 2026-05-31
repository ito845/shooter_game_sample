require "p5"

module ShooterGame
    module ContextUsage
        module Score
            def init_score
                self[:score] = 0
                self[:high_score] = 0 unless key?(:high_score)
                self[:new_record] = false
            end

            def score
                self[:score]
            end

            def high_score
                self[:high_score]
            end

            def new_record?
                self[:new_record]
            end

            def add_score(score)
                self[:score] += score
            end

            def update_high_score
                self[:new_record] = false
                return unless score > high_score

                self[:high_score] = score
                self[:new_record] = true
            end
        end
    end
end
