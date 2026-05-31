require "game_lib_sample/input"
require "game_lib_sample/scene"

module ShooterGame
	module Scene
		class GameOver < GameLibSample::Scene
			WARNING = 0xE0
			ACCENT = 0xFC
			TEXT = 0xFF

			def init(context)
				context.update_high_score
			end

			def update(context)
				if GameLibSample::Input.key_down?(:z) || GameLibSample::Input.key_down?(:enter)
					GameLibSample::SceneManager.next(
						next_scene: :main_game,
						next_context: context,
						need_init: true,
						clear_stack: true
					)
					return
				end

				if GameLibSample::Input.key_down?(:t) || GameLibSample::Input.key_down?(:esc)
					GameLibSample::SceneManager.next(
						next_scene: :title,
						next_context: context,
						need_init: true,
						clear_stack: true
					)
				end
			end

			def draw(context)
				p5 = context.p5

				p5.background(0x00)
				p5.text_align(:left)
				p5.text_color(TEXT)
				p5.text("Game Over", 24, 24)
				p5.text_color(0x92)
				p5.text("One more run?", 24, 40)
				p5.text_color(WARNING)
				p5.text("Final score: #{context.score}", 124, 132)
				p5.text_color(TEXT)
				p5.text("High score: #{context.high_score}", 124, 150)
				p5.text_color(context.new_record? ? ACCENT : TEXT)
				p5.text(context.new_record? ? "New record!" : "Press Z or Enter to retry.", 124, 168)
				p5.text_color(TEXT)
				p5.text("Press T or Esc to go back to title.", 124, 186)
				p5.commit
			end
		end
	end
end
