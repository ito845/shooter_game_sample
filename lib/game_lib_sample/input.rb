module GameLibSample
  module Input
    class << self
      def reset
        @pressed_keys = []
        @key_down = []
        @key_up = []
        @events = []
      end

      def update
        return false unless $keyboard

        previous_keys = @pressed_keys || []
        @events = drain_events
        @pressed_keys = capture_pressed_keys
        @key_down = []
        @key_up = []

        @pressed_keys.each do |key|
          push_unique(@key_down, key) unless previous_keys.include?(key)
        end

        @events.each do |key|
          push_unique(@key_down, key) unless previous_keys.include?(key)
        end

        previous_keys.each do |key|
          push_unique(@key_up, key) unless @pressed_keys.include?(key)
        end

        true
      end

      def key_down?(key)
        include_key?(@key_down, key)
      end

      def key_up?(key)
        include_key?(@key_up, key)
      end

      def key_pressed?(key)
        include_key?(@pressed_keys, key)
      end

      private

      def push_unique(keys, key)
        keys << key unless key.nil? || keys.include?(key)
      end

      def include_key?(keys, key)
        keys && keys.include?(normalize_key(key))
      end

      def normalize_key(key)
        return nil unless key

        if key.is_a?(Symbol)
          return key
        end

        if key.is_a?(String)
          return key.downcase.to_sym
        end

        key_symbol(key)
      end

      def capture_pressed_keys
        modifier = USB::Host.keyboard_modifier
        keys = []

        USB::Host.keyboard_keycodes.each do |keycode|
          next unless keycode && keycode != 0

          resolved = $keyboard.send(:resolve_key, keycode, modifier)
          push_unique(keys, key_symbol(resolved))
        end

        keys
      end

      def drain_events
        keys = []

        loop do
          key = $keyboard.read_char
          break unless key

          push_unique(keys, key_symbol(key))
        end

        keys
      end

      def key_symbol(key)
        return nil unless key

        if key == Keyboard::CTRL_C
          :ctrl_c
        elsif key.respond_to?(:ctrl?) && key.ctrl?
          ("ctrl_" + key.name.to_s).to_sym
        elsif key.respond_to?(:name)
          key.name
        else
          nil
        end
      end
    end

    reset
  end
end