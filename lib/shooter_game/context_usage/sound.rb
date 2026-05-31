module ShooterGame
    module ContextUsage
        module Sound
            LEVELS = [0, 1, 2, 3]
            DEFAULT_LEVEL = 2
            LABELS = {
                0 => "OFF",
                1 => "LOW",
                2 => "MID",
                3 => "HIGH",
            }

            def init_sound
                set_volume(DEFAULT_LEVEL)
            end

            def volume
                self[:volume]
            end

            def volume_label
                LABELS[volume]
            end

            def set_volume(level)
                normalized = LEVELS.include?(level) ? level : DEFAULT_LEVEL
                self[:volume] = normalized
                self[:audio].set_volume_level(normalized) if self[:audio]
            end
        end
    end
end
