require "game_lib_sample/scene"
require "shooter_game/context_hash"
require "shooter_game/ui/select_box"
require "shooter_game/scene/title"
require "shooter_game/scene/main_game"
require "shooter_game/scene/options"
require "shooter_game/scene/options/difficulty_config"
require "shooter_game/scene/options/sound_config"
require "shooter_game/scene/game_over"

module ShooterGame
    module Main
        module_function

        def run
            start
        end

        def start
            ShooterGame.start
        end
    end

    class << self
        def start
            raise "keyboard is not initialized" unless $keyboard

            context = ContextHash.new

            GameLibSample::SceneManager.reset
            GameLibSample::SceneManager.register(name: :title, scene: Scene::Title.new)
            GameLibSample::SceneManager.register(name: :main_game, scene: Scene::MainGame.new)
            GameLibSample::SceneManager.register(name: :options, scene: Scene::Options.new)
            GameLibSample::SceneManager.register(name: :options_difficulty, scene: Scene::OptionsMenu::DifficultyConfig.new)
            GameLibSample::SceneManager.register(name: :options_sound, scene: Scene::OptionsMenu::SoundConfig.new)
            GameLibSample::SceneManager.register(name: :game_over, scene: Scene::GameOver.new)

            GameLibSample::SceneManager.next(
                next_scene: :title,
                next_context: context,
                need_init: true,
                clear_stack: true
            )

            while GameLibSample::SceneManager.running?
                GameLibSample::SceneManager.update
                context.audio.update if context && context.audio
                Task.pass
            end
        ensure
            context.audio.shutdown if context && context.audio
            if context && context.p5
                context.p5.background(0x00)
                context.p5.commit
            end
        end
    end
end
