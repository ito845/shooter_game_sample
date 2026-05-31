require "game_lib_sample/collidable"
require "shooter_game/core/bullet"

module ShooterGame
    module Core
        class Enemy
            include GameLibSample::Collidable

            WIDTH = 14
            HEIGHT = 14
            COLOR = 0xE0
            BULLET_SPEED = 6

            attr_reader :pos, :offset, :score

            def initialize(x = 0, y = 0, speed: 3, fire_interval: 45, hp: 1, score: 10, renderer: nil)
                @pos = GameLibSample::Pos.new(x, y)
                @offset = GameLibSample::Pos.new(0, 0)
                @speed = speed
                @fire_interval = fire_interval
                @fire_cooldown = fire_interval
                @hp = hp
                @score = score
                @fired_bullets = []
                @destroyed = false
            end

            def update(target_x = nil, target_y = nil)
                return if destroyed?

                @pos.move_by(0, @speed)
                @fire_cooldown -= 1
                return unless @fire_cooldown <= 0

                velocity_x, velocity_y = bullet_velocity(target_x, target_y)

                @fired_bullets << Bullet.new(
                    @pos.x + WIDTH / 2 - 1,
                    @pos.y + HEIGHT,
                    width: 4,
                    height: 4,
                    velocity_x: velocity_x,
                    velocity_y: velocity_y,
                    damage: 1,
                    color: COLOR
                )
                @fire_cooldown = @fire_interval
            end

            def fired_bullets
                bullets = @fired_bullets
                @fired_bullets = []
                bullets
            end

            def draw(p5)
                p5.fill(COLOR)
                p5.no_stroke
                p5.rect(@pos.x, @pos.y, WIDTH, HEIGHT)
            end

            def hit(damage = 1)
                return if destroyed?

                @hp -= damage
                @destroyed = @hp <= 0
            end

            def destroyed?
                @destroyed
            end

            def out_of_screen?(x, y, width, height)
                right = x + width
                bottom = y + height

                @pos.x + WIDTH < x || @pos.x > right || @pos.y + HEIGHT < y || @pos.y > bottom
            end

            def shape
                [
                    GameLibSample::Pos.new(0, 0),
                    GameLibSample::Pos.new(WIDTH, 0),
                    GameLibSample::Pos.new(WIDTH, HEIGHT),
                    GameLibSample::Pos.new(0, HEIGHT),
                ]
            end

            private

            def bullet_velocity(target_x, target_y)
                return [0, BULLET_SPEED] if target_x.nil? || target_y.nil?

                origin_x = @pos.x + WIDTH / 2 - 1
                origin_y = @pos.y + HEIGHT
                delta_x = target_x - origin_x
                delta_y = target_y - origin_y
                distance = Math.sqrt(delta_x * delta_x + delta_y * delta_y)

                return [0, BULLET_SPEED] if distance <= 0

                [delta_x * BULLET_SPEED / distance, delta_y * BULLET_SPEED / distance]
            end
        end
    end
end