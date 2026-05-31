require "shooter_game/core/enemy"

module ShooterGame
    module Core
        module EnemySpawner
            class << self
                def spawn_enemies(enemies, frame_count, spawn_interval, max_enemies, spawn_area_pos1, spawn_area_pos2, speed)
                    return enemies if max_enemies <= 0
                    return enemies if enemies.length >= max_enemies
                    return enemies if spawn_interval <= 0
                    return enemies unless frame_count % spawn_interval == 0

                    width = spawn_area_pos2.x - spawn_area_pos1.x - Enemy::WIDTH
                    width = 0 if width < 0

                    enemies << Enemy.new(
                        spawn_area_pos1.x + rand(width + 1),
                        spawn_area_pos1.y,
                        speed: speed
                    )
                end

                def spqen_enemeis(enemies, frame_count, spawn_interval, max_enemies, spawn_area_pos1, spawn_area_pos2, speed)
                    spawn_enemies(enemies, frame_count, spawn_interval, max_enemies, spawn_area_pos1, spawn_area_pos2, speed)
                end
            end
        end
    end
end