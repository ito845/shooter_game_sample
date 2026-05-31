require "game_lib_sample/scene"
require "shooter_game/core/player"
require "shooter_game/core/enemy_spawner"

module ShooterGame
    module Core
        class GameManager
            class Area
                attr_reader :x, :y, :width, :height

                def initialize(x, y, width, height)
                    @x = x
                    @y = y
                    @width = width
                    @height = height
                end
            end

            attr_reader :player

            def initialize(x, y, width, height)
                @area = Area.new(x, y, width, height)
                @frame_count = 0
                @player = Player.new(
                    x + width / 2 - Player::WIDTH / 2,
                    y + height - Player::HEIGHT - 16,
                    bounds: @area
                )
                @enemies = []
                @player_bullets = []
                @enemy_bullets = []
            end

            def update(context)
                @frame_count += 1

                if @player.destroyed?
                    GameLibSample::SceneManager.next(
                        next_scene: :game_over,
                        next_context: context,
                        need_init: true,
                        clear_stack: true
                    )
                    return
                end

                handle_destroyed_enemies(context)

                @player.update
                new_player_bullets = @player.fired_bullets
                play_shot_sound(context, new_player_bullets)
                update_enemies

                update_bullets

                resolve_player_hits(context)

                resolve_enemy_hits

                @player_bullets += new_player_bullets
                append_enemy_bullets

                handle_destroyed_enemies(context)
                if @player.destroyed?
                    GameLibSample::SceneManager.next(
                        next_scene: :game_over,
                        next_context: context,
                        need_init: true,
                        clear_stack: true
                    )
                    return
                end

                cleanup_objects
                @enemies = EnemySpawner.spawn_enemies(
                    @enemies,
                    @frame_count,
                    enemy_spawn_interval(context),
                    max_enemies(context),
                    spawn_area_pos1,
                    spawn_area_pos2,
                    enemy_speed(context)
                )
            end

            def draw(context)
                p5 = context.p5

                @enemies.each { |enemy| enemy.draw(p5) }
                @enemy_bullets.each { |bullet| bullet.draw(p5) }
                @player_bullets.each { |bullet| bullet.draw(p5) }
                @player.draw(p5)
            end

            def area
                @area
            end

            private

            def handle_destroyed_enemies(context)
                remaining_enemies = []

                @enemies.each do |enemy|
                    if enemy.destroyed?
                        context.add_score(enemy.score)
                    else
                        remaining_enemies << enemy
                    end
                end

                @enemies = remaining_enemies
            end

            def cleanup_objects
                remaining_enemies = []
                @enemies.each do |enemy|
                    next if enemy.destroyed?
                    next if enemy.out_of_screen?(area.x, area.y, area.width, area.height)

                    remaining_enemies << enemy
                end
                @enemies = remaining_enemies

                remaining_player_bullets = []
                @player_bullets.each do |bullet|
                    next if bullet.destroyed?
                    next if bullet.out_of_screen?(area.x, area.y, area.width, area.height)

                    remaining_player_bullets << bullet
                end
                @player_bullets = remaining_player_bullets

                remaining_enemy_bullets = []
                @enemy_bullets.each do |bullet|
                    next if bullet.destroyed?
                    next if bullet.out_of_screen?(area.x, area.y, area.width, area.height)

                    remaining_enemy_bullets << bullet
                end
                @enemy_bullets = remaining_enemy_bullets
            end

            def enemy_spawn_interval(context)
                context.enemy_spawn_interval
            end

            def max_enemies(context)
                context.max_enemies
            end

            def enemy_speed(context)
                context.enemy_speed
            end

            def update_enemies
                @enemies.each do |enemy|
                    enemy.update(player_target_x, player_target_y)
                end
            end

            def update_bullets
                @player_bullets.each do |bullet|
                    bullet.update
                end

                @enemy_bullets.each do |bullet|
                    bullet.update
                end
            end

            def resolve_player_hits(context)
                @enemy_bullets.each do |bullet|
                    next unless @player.intersect?(bullet)

                    @player.hit(bullet.damage)
                    bullet.destroy
                    break
                end
            end

            def resolve_enemy_hits
                @player_bullets.each do |bullet|
                    next if bullet.destroyed?

                    @enemies.each do |enemy|
                        next unless enemy.intersect?(bullet)

                        enemy.hit(bullet.damage)
                        bullet.destroy
                        break
                    end
                end
            end

            def append_enemy_bullets
                @enemies.each do |enemy|
                    @enemy_bullets += enemy.fired_bullets
                end
            end

            def player_target_x
                @player.pos.x + Player::WIDTH / 2
            end

            def player_target_y
                @player.pos.y + Player::HEIGHT / 2
            end

            def spawn_area_pos1
                GameLibSample::Pos.new(@area.x, @area.y + 8)
            end

            def spawn_area_pos2
                GameLibSample::Pos.new(@area.x + @area.width, @area.y + 8)
            end

            def play_shot_sound(context, bullets)
                return unless context.audio
                return if bullets.empty?

                bullet = bullets[0]
                context.audio.play_shot(x: bullet.pos.x)
            end

        end
    end
end