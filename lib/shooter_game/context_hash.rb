require "shooter_game/context_usage/p5"
require "shooter_game/context_usage/difficulty"
require "shooter_game/context_usage/score"
require "shooter_game/context_usage/audio"
require "shooter_game/context_usage/sound"

module ShooterGame
    class ContextHash < Hash
        include ContextUsage::P5
        include ContextUsage::Difficulty
        include ContextUsage::Score
        include ContextUsage::Audio
        include ContextUsage::Sound

        def initialize
            super
            init_p5
            init_difficulty
            init_score
            init_sound
            init_audio
        end
    end
end
