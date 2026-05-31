require "game_lib_sample/scene"
require "shooter_game/ui/select_box"

module ShooterGame
    module Scene
        class Title < GameLibSample::Scene
            TEXT = 0xFF
            MUTED = 0x92

            def init(context)
                @select_menu = UI::SelectBox.new([
                    {
                        text: "Start Game",
                        on_selected: lambda do |ctx|
                            GameLibSample::SceneManager.next(
                                next_scene: :main_game,
                                next_context: ctx,
                                need_init: true,
                                clear_stack: true
                            )
                        end,
                    },
                    {
                        text: "Options",
                        on_selected: lambda do |ctx|
                            GameLibSample::SceneManager.stack(
                                next_scene: :options,
                                next_context: ctx,
                                need_init: true
                            )
                        end,
                    },
                    { text: "Exit", on_selected: ->(_ctx) { GameLibSample::SceneManager.exit } },
                ])
            end

            def update(context)
                @select_menu.update(context)
            end

            def draw(context)
                p5 = context.p5

                p5.background(0x00)
                p5.text_align(:left)
                p5.text_color(TEXT)
                p5.text("Shooting Game", 24, 24)

                p5.text_color(TEXT)
                p5.text("Menu", 28, 178)
                @select_menu.draw(p5, x: 28, y: 198, width: 240, height: 110)

                p5.text_color(TEXT)
                p5.text("Current Settings", 328, 178)
                p5.text("Difficulty: #{context.difficulty_name}", 328, 206)
                p5.text("Volume: #{context.volume_label}", 328, 222)

                p5.commit
            end
        end
    end
end
