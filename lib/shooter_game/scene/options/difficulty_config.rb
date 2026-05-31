require "game_lib_sample/input"
require "game_lib_sample/scene"
require "shooter_game/ui/select_box"

module ShooterGame
	module Scene
		module OptionsMenu
			class DifficultyConfig < GameLibSample::Scene
				TEXT = 0xFF
				MUTED = 0x92
				OPTIONS = [
					{ key: :easy, text: "Easy" },
					{ key: :normal, text: "Normal" },
					{ key: :hard, text: "Hard" },
				]

				def init(context)
					@select_menu = UI::SelectBox.new(
						difficulty_options + [{text: "Back", on_selected: ->(_ctx) { GameLibSample::SceneManager.pop } }],
						selected_index: difficulty_option_index(context)
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
					p5.text("Difficulty", 24, 24)
					p5.text_color(TEXT)
					@select_menu.draw(p5, x: 28, y: 104, width: 552, height: 152)
					p5.commit
				end

				private

				def difficulty_options
					OPTIONS.map do |option|
						{
							text: option[:text],
							on_selected: ->(ctx) { select_difficulty(ctx, option[:key]) },
						}
					end
				end

				def difficulty_option_index(context)
					OPTIONS.index { |option| option[:key] == context.difficulty_key } || 0
				end

				def select_difficulty(context, key)
					context.set_difficulty(key)
					GameLibSample::SceneManager.pop
				end
			end
		end
	end
end