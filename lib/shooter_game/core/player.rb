require "game_lib_sample/collidable"
require "game_lib_sample/input"
require "picorabbit/bmp"
require "shooter_game/core/bullet"

module ShooterGame
    module Core
        class Player
            include GameLibSample::Collidable

            def self.load_sprite(file_path)
                sprite = ::PicoRabbit::BMP.load(file_path)
                sprite.mask
                sprite
            end

            SPRITE = load_sprite("data/player.bmp")
            WIDTH = 14
            HEIGHT = 14
            SPEED = 5
            SHOT_COOLDOWN = 8
            COLOR = 0x1C

            attr_reader :pos, :offset, :hp

            def initialize(x = 0, y = 0, bounds: nil, renderer: nil)
                @pos = GameLibSample::Pos.new(x, y)
                @offset = GameLibSample::Pos.new(0, 0)
                @bounds = bounds
                @hp = 3
                @shot_cooldown = 0
                @fired_bullets = []
                @destroyed = false
            end

            def update
                return if destroyed?

                @shot_cooldown -= 1 if @shot_cooldown > 0

                move_x = 0
                move_y = 0
                move_x -= SPEED if GameLibSample::Input.key_pressed?(:left)
                move_x += SPEED if GameLibSample::Input.key_pressed?(:right)
                move_y -= SPEED if GameLibSample::Input.key_pressed?(:up)
                move_y += SPEED if GameLibSample::Input.key_pressed?(:down)

                @pos.move_by(move_x, move_y)
                clamp_to_bounds
                fire if fire_requested?
            end

            def fired_bullets
                bullets = @fired_bullets
                @fired_bullets = []
                bullets
            end

            def draw(p5)
                p5.image_masked(SPRITE.data, SPRITE.mask, @pos.x, @pos.y, SPRITE.width, SPRITE.height)
            end

            def hit(damage = 1)
                return if destroyed?

                @hp -= damage
                @destroyed = @hp <= 0
            end

            def destroyed?
                @destroyed
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

            def clamp_to_bounds
                return unless @bounds

                min_x = @bounds.x
                min_y = @bounds.y
                max_x = @bounds.x + @bounds.width - WIDTH
                max_y = @bounds.y + @bounds.height - HEIGHT

                @pos.x = min_x if @pos.x < min_x
                @pos.y = min_y if @pos.y < min_y
                @pos.x = max_x if @pos.x > max_x
                @pos.y = max_y if @pos.y > max_y
            end

            def fire_requested?
                @shot_cooldown == 0 && (GameLibSample::Input.key_down?(:z) || GameLibSample::Input.key_down?(:enter))
            end

            def fire
                @fired_bullets << Bullet.new(
                    @pos.x + WIDTH / 2 - 1,
                    @pos.y - 8,
                    velocity_y: -8,
                    damage: 1
                )
                @shot_cooldown = SHOT_COOLDOWN
            end
        end
    end
end