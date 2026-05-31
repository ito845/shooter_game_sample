require "p5"
require "game_lib_sample/input"

module ShooterGame
    module UI
        class SelectBox
            TEXT = 0xFF
            MUTED = 0x92

            attr_reader :options, :selected_index

            # options: [{ text: "Option 1", on_selected: ->(context) { ... } }, ...]
            def initialize(options, selected_index: 0)
                @options = options
                @selected_index = options.empty? ? 0 : selected_index % options.size
            end

            def update(context)
                if GameLibSample::Input.key_down?(:up)
                    @selected_index = (@selected_index - 1) % @options.size
                elsif GameLibSample::Input.key_down?(:down)
                    @selected_index = (@selected_index + 1) % @options.size
                elsif GameLibSample::Input.key_down?(:enter) || GameLibSample::Input.key_down?(:z)
                    return invoke_callback(:on_selected, context)
                end
            end

            def draw(p5, x:, y:, width:, height:)
                option_height = height / @options.size
                p5.text_align(:left)

                @options.each_with_index do |option, index|
                    option_y = y + index * option_height
                    label = index == @selected_index ? "> #{option_text(option)}" : "  #{option_text(option)}"

                    p5.text_color(index == @selected_index ? TEXT : MUTED)
                    p5.text(label, x, option_y + option_height / 2 - 2)
                end
            end

            private

            def option_text(option)
                option[:text].to_s
            end

            def invoke_callback(name, context)
                callback = @options[@selected_index][name]
                return unless callback

                callback.call(context)
            end
        end
    end
end
