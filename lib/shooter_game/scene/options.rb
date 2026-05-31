require "game_lib_sample/input"
require "game_lib_sample/scene"
require "shooter_game/ui/select_box"

module ShooterGame
	module Scene
		class Options < GameLibSample::Scene
			MUTED = 0x92
			TEXT = 0xFF

			def init(context)
				@select_menu = UI::SelectBox.new(
					[
						{
							text: "Difficulty Settings",
							on_selected: lambda do |ctx|
								GameLibSample::SceneManager.stack(
									next_scene: :options_difficulty,
									next_context: ctx,
									need_init: true
								)
							end,
						},
						{
							text: "Sound Settings",
							on_selected: lambda do |ctx|
								GameLibSample::SceneManager.stack(
									next_scene: :options_sound,
									next_context: ctx,
									need_init: true
								)
							end,
						},
						{ text: "Back", on_selected: ->(_ctx) { GameLibSample::SceneManager.pop } },
					]
				)
			end

			def update(context)
				if GameLibSample::Input.key_down?(:esc) || GameLibSample::Input.key_down?(:q)
					GameLibSample::SceneManager.pop
					return
				end

				@select_menu.update(context)
			end

			def draw(context)
				p5 = context.p5

				p5.background(0x00)
				p5.text_align(:left)
				p5.text_color(TEXT)
				p5.text("Options", 24, 24)
				p5.text("Menu", 28, 88)
				@select_menu.draw(p5, x: 28, y: 108, width: 248, height: 196)

				p5.text_color(TEXT)
				p5.text("Current Settings", 328, 88)
				p5.text("Difficulty: #{context.difficulty_name}", 328, 108)
				p5.text("Volume: #{context.volume_label}", 328, 124)

				p5.commit
			end
		end
	end
end
