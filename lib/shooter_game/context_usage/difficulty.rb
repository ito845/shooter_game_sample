module ShooterGame
    module ContextUsage
        module Difficulty
            ORDER = [:easy, :normal, :hard]

            EASY = {
                key: :easy,
                label: "Easy",
                enemy_spawn_interval: 32,
                enemy_speed: 2,
                score_multiplier: 1,
            }
            NORMAL = {
                key: :normal,
                label: "Normal",
                enemy_spawn_interval: 24,
                enemy_speed: 3,
                score_multiplier: 2,
            }
            HARD = {
                key: :hard,
                label: "Hard",
                enemy_spawn_interval: 16,
                enemy_speed: 4,
                score_multiplier: 3,
            }

            TABLE = {
                easy: EASY,
                normal: NORMAL,
                hard: HARD,
            }

            def init_difficulty
                set_difficulty(:normal)
            end

            def difficulty
                self[:difficulty]
            end

            def difficulty_key
                self[:difficulty_key]
            end

            def difficulty_name
                difficulty[:label]
            end

            def enemy_spawn_interval
                self[:enemy_spawn_rate] || difficulty[:enemy_spawn_interval] || 24
            end

            def max_enemies
                self[:max_enemies] || 6
            end

            def enemy_speed
                self[:enemy_speed] || difficulty[:enemy_speed] || 3
            end

            def set_difficulty(difficulty)
                normalized = TABLE[difficulty] ? difficulty : :normal
                self[:difficulty_key] = normalized
                self[:difficulty] = TABLE[normalized]
            end

            def next_difficulty
                shift_difficulty(1)
            end

            def previous_difficulty
                shift_difficulty(-1)
            end

            private

            def shift_difficulty(step)
                current_index = ORDER.index(difficulty_key) || ORDER.index(:normal)
                next_index = (current_index + step) % ORDER.length
                set_difficulty(ORDER[next_index])
            end
        end
    end
end
