require "shooter_game/game_audio"

module ShooterGame
    module ContextUsage
        module Audio
            def init_audio
                self[:audio] = GameAudio.new(volume_level: volume)
            end

            def audio
                self[:audio]
            end
        end
    end
end