require "game_lib_sample/input"

module GameLibSample
  class Scene
    def init(context)
    end

    def update(context)
    end

    def draw(context)
    end
  end

  module SceneManager
    class << self
      def reset
        @scenes = {}
        @scene_stack = []
        @current_frame = nil
        @pending_transition = nil
        @exited = false
        Input.reset
      end

      def register(name:, scene:)
        @scenes[name] = scene
      end

      def update
        apply_pending_transition
        return if @exited || !@current_frame

        Input.update

        frame = @current_frame
        frame[:scene].update(frame[:context])

        apply_pending_transition
        return if @exited || !@current_frame

        frame = @current_frame
        frame[:scene].draw(frame[:context])
      end

      def next(next_scene:, next_context: {}, need_init: true, clear_stack: false)
        @pending_transition = {
          type: :next,
          scene_name: next_scene,
          context: normalize_context(next_context),
          need_init: need_init,
          clear_stack: clear_stack,
        }
      end

      def stack(next_scene:, next_context: {}, need_init: true)
        @pending_transition = {
          type: :stack,
          scene_name: next_scene,
          context: normalize_context(next_context),
          need_init: need_init,
        }
      end

      def pop
        @pending_transition = { type: :pop }
      end

      def exit
        @pending_transition = { type: :exit }
      end

      def running?
        !@exited
      end

      def exited?
        @exited
      end

      def current_scene_name
        @current_frame ? @current_frame[:name] : nil
      end

      def current_context
        @current_frame ? @current_frame[:context] : nil
      end

      private

      def normalize_context(context)
        context || {}
      end

      def build_frame(name, context, need_init)
        scene = @scenes[name]
        raise ArgumentError, "unknown scene: #{name}" unless scene

        frame = {
          name: name,
          scene: scene,
          context: normalize_context(context),
        }
        scene.init(frame[:context]) if need_init
        frame
      end

      def apply_pending_transition
        loop do
          transition = @pending_transition
          @pending_transition = nil
          break unless transition

          case transition[:type]
          when :next
            @scene_stack.clear if transition[:clear_stack]
            @current_frame = build_frame(
              transition[:scene_name],
              transition[:context],
              transition[:need_init]
            )
          when :stack
            @scene_stack << @current_frame if @current_frame
            @current_frame = build_frame(
              transition[:scene_name],
              transition[:context],
              transition[:need_init]
            )
          when :pop
            if @scene_stack.empty?
              @current_frame = nil
              @exited = true
            else
              @current_frame = @scene_stack.pop
            end
          when :exit
            @scene_stack.clear
            @current_frame = nil
            @exited = true
          end
        end
      end
    end

    reset
  end
end