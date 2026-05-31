require "game_lib_sample/input"
require "game_lib_sample/scene"
require "shooter_game/ui/select_box"

module ShooterGame
	module Scene
		module OptionsMenu
			class SoundConfig < GameLibSample::Scene
				MUTED = 0x92
				OPTIONS = [
					{ level: 0, text: "OFF" },
					{ level: 1, text: "LOW" },
					{ level: 2, text: "MID" },
					{ level: 3, text: "HIGH" },
				]

				def init(context)
					@select_menu = UI::SelectBox.new(
						sound_options + [{text: "Back", on_selected: ->(_ctx) { GameLibSample::SceneManager.pop } }],
						selected_index: sound_option_index(context)
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
					p5.text_color(0xFF)
					p5.text("Sound", 24, 24)
					p5.text_color(0xFF)
					@select_menu.draw(p5, x: 28, y: 104, width: 552, height: 152)
					p5.commit
				end

				private

				def sound_options
					OPTIONS.map do |option|
						{
							text: option[:text],
							on_selected: ->(ctx) { select_volume(ctx, option[:level]) },
						}
					end
				end

				def sound_option_index(context)
					OPTIONS.index { |option| option[:level] == context.volume } || 0
				end

				def select_volume(context, level)
					context.set_volume(level)
					GameLibSample::SceneManager.pop
				end
			end
		end
	end
end