require "game_lib_sample/input"
require "game_lib_sample/scene"
require "shooter_game/core/game_manager"

module ShooterGame
	module Scene
		class MainGame < GameLibSample::Scene
			PLAYER_SPEED = 5
			PLAYER_SIZE = 14
			BULLET_WIDTH = 3
			BULLET_HEIGHT = 8
			BULLET_SPEED = 8
			SHOT_COOLDOWN = 8
			ENEMY_SIZE = 14
			SUCCESS = 0x1C
			TEXT = 0xFF
			MUTED = 0x92
			ACCENT = 0xFC
			WARNING = 0xE0

			def init(context)
				context.init_score
				@message = nil
				@game_manager = Core::GameManager.new(34, 94, context.p5.width - 68, 296)
				context.audio.start_main_bgm if context.audio
			end

			def update(context)
				ensure_main_bgm(context)

				if GameLibSample::Input.key_down?(:o)
					context.audio.stop_main_bgm if context.audio
					GameLibSample::SceneManager.stack(
						next_scene: :options,
						next_context: context,
						need_init: true
					)
					return
				end

				if GameLibSample::Input.key_down?(:esc) || GameLibSample::Input.key_down?(:q)
					context.audio.stop_main_bgm if context.audio
					GameLibSample::SceneManager.next(
						next_scene: :title,
						next_context: context,
						need_init: true,
						clear_stack: true
					)
					return
				end

				@game_manager.update(context)
				context.audio.stop_main_bgm if context.audio && @game_manager.player.destroyed?
			end

			def draw(context)
				p5 = context.p5

				p5.background(0x00)
				p5.fill(0x04)
				p5.no_stroke
				p5.rect(28, 74, 584, 336)
				draw_hud(context)
				@game_manager.draw(context)
				p5.commit
			end

			private

			def draw_hud(context)
				p5 = context.p5
				p5.text_color(SUCCESS)
				p5.text("Score: #{context.score}  HP: #{@game_manager.player.hp}", 40, 40)
			end

			def ensure_main_bgm(context)
				return unless context.audio

				context.audio.start_main_bgm unless context.audio.main_bgm_playing?
			end
		end
	end
end
