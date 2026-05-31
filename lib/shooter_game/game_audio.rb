require "board/pwm_audio"

module ShooterGame
    class GameAudio
        BGM_CHANNEL = 0
        SHOT_CHANNEL = 1
        BGM_NOTE_DURATION_MS = 720
        SHOT_DURATION_FRAMES = 2
        PAN_CENTER = 8
        MAX_VOLUME_BY_LEVEL = {
            0 => 0,
            1 => 4,
            2 => 8,
            3 => 12,
        }
        C3 = Board::PWMAudio::C4
        D3 = Board::PWMAudio::D4
        DS3 = Board::PWMAudio::DS4
        C4 = Board::PWMAudio::C5
        D4 = Board::PWMAudio::D5
        DS4 = Board::PWMAudio::DS5
        BGM_WAVEFORM = Board::PWMAudio::TRIANGLE
        MAIN_BGM = [
            C3, C3, C4, D3,
            D3, C4, D3, D3,
            DS4, DS3, DS3, DS4,
            DS3, DS4, D3, D4,
        ].map do |frequency|
            {
                freq: frequency,
                duration_ms: BGM_NOTE_DURATION_MS,
                waveform: BGM_WAVEFORM,
                volume: 6,
            }
        end.freeze
        SHOT_FREQUENCY = Board::PWMAudio::C6
        SHOT_VOLUME = 10

        def initialize(volume_level: 2)
            @audio = Board::PWMAudio.new
            @volume_level = 2
            @bgm_playing = false
            @bgm_index = 0
            @bgm_next_at_ms = nil
            @shot_active = false
            @shot_frames_remaining = 0
            set_volume_level(volume_level)
        end

        def set_volume_level(level)
            normalized = MAX_VOLUME_BY_LEVEL.key?(level) ? level : 2
            @volume_level = normalized
            if normalized == 0
                @audio.stop_all
                @shot_active = false
                @shot_frames_remaining = 0
            end
            normalized
        end

        def start_main_bgm(now_ms = Machine.board_millis)
            @bgm_playing = true
            @bgm_index = 0
            @bgm_next_at_ms = now_ms
            @audio.stop(BGM_CHANNEL)
        end

        def stop_main_bgm
            @bgm_playing = false
            @bgm_next_at_ms = nil
            @audio.stop(BGM_CHANNEL)
        end

        def main_bgm_playing?
            @bgm_playing
        end

        def play_shot(x: nil)
            volume = scaled_volume(SHOT_VOLUME)
            if volume == 0
                stop_shot_channel
                return
            end

            @audio.pan(SHOT_CHANNEL, pan_from_x(x))
            @audio.tone(
                SHOT_CHANNEL,
                SHOT_FREQUENCY,
                waveform: Board::PWMAudio::SQUARE,
                volume: volume
            )
            @shot_active = true
            @shot_frames_remaining = SHOT_DURATION_FRAMES
        end

        def update(now_ms = Machine.board_millis)
            update_bgm(now_ms)
            update_shot
            @audio.update
        end

        def shutdown
            @audio.deinit
        end

        private

        def update_bgm(now_ms)
            unless @bgm_playing
                @audio.stop(BGM_CHANNEL)
                return
            end

            @bgm_next_at_ms ||= now_ms
            while now_ms >= @bgm_next_at_ms
                play_bgm_note(MAIN_BGM[@bgm_index])
                @bgm_next_at_ms += MAIN_BGM[@bgm_index][:duration_ms]
                @bgm_index = (@bgm_index + 1) % MAIN_BGM.length
            end
        end

        def play_bgm_note(note)
            volume = scaled_volume(note[:volume])
            if volume == 0 || note[:freq] == 0
                @audio.stop(BGM_CHANNEL)
                return
            end

            @audio.pan(BGM_CHANNEL, PAN_CENTER)
            @audio.tone(
                BGM_CHANNEL,
                note[:freq],
                waveform: note[:waveform],
                volume: volume
            )
        end

        def update_shot
            return unless @shot_active

            @shot_frames_remaining -= 1 if @shot_frames_remaining > 0
            stop_shot_channel if @shot_frames_remaining <= 0
        end

        def scaled_volume(base_volume)
            max_volume = MAX_VOLUME_BY_LEVEL[@volume_level]
            return 0 if max_volume == 0

            volume = (base_volume * max_volume) / MAX_VOLUME_BY_LEVEL[3]
            volume > 0 ? volume : 1
        end

        def pan_from_x(x)
            return PAN_CENTER if x.nil?
            return 0 if x < 120
            return 4 if x < 220
            return PAN_CENTER if x < 340
            return 12 if x < 440

            15
        end

        def stop_shot_channel
            return unless @shot_active

            @audio.stop(SHOT_CHANNEL)
            @shot_active = false
            @shot_frames_remaining = 0
        end
    end
end