require "game_lib_sample/collidable"

module ShooterGame
    module Core
        class Bullet
            include GameLibSample::Collidable

            DEFAULT_COLOR = 0xFC

            attr_reader :pos, :offset, :damage

            def initialize(x = 0, y = 0, width: 3, height: 8, velocity_x: 0, velocity_y: -8, damage: 1, color: DEFAULT_COLOR, renderer: nil)
                @pos = GameLibSample::Pos.new(x, y)
                @offset = GameLibSample::Pos.new(0, 0)
                @width = width
                @height = height
                @velocity_x = velocity_x
                @velocity_y = velocity_y
                @damage = damage
                @color = color
                @destroyed = false
            end

            def update
                return if destroyed?

                @pos.move_by(@velocity_x, @velocity_y)
            end

            def draw(p5)
                p5.fill(@color)
                p5.no_stroke
                p5.rect(@pos.x, @pos.y, @width, @height)
            end

            def destroy
                @destroyed = true
            end

            def destroyed?
                @destroyed
            end

            def out_of_screen?(x, y, width, height)
                right = x + width
                bottom = y + height

                @pos.x + @width < x || @pos.x > right || @pos.y + @height < y || @pos.y > bottom
            end

            def shape
                [
                    GameLibSample::Pos.new(0, 0),
                    GameLibSample::Pos.new(@width, 0),
                    GameLibSample::Pos.new(@width, @height),
                    GameLibSample::Pos.new(0, @height),
                ]
            end

        end
    end
end