module GameLibSample
  class Pos
    attr_accessor :x, :y

    def initialize(x, y)
      @x = x
      @y = y
    end

    def set(x = nil, y = nil)
      @x = x unless x.nil?
      @y = y unless y.nil?
      self
    end

    def move_by(x, y)
      @x += x
      @y += y
      self
    end

    def to_a
      [@x, @y]
    end
  end

  module Collidable
    def intersect?(other)
      Collidable.intersect?(self, other)
    end

    def intersects?(others)
      Collidable.intersects?(self, others)
    end

    class << self
      def intersect?(left, right)
        left_points = world_points(left)
        right_points = world_points(right)
        return false if left_points.empty? || right_points.empty?

        left_edges = edges(left_points)
        right_edges = edges(right_points)

        if left_edges.empty? && right_edges.empty?
          return same_point?(left_points.first, right_points.first)
        end

        if left_edges.empty?
          return point_intersects_shape?(left_points.first, right_points)
        end

        if right_edges.empty?
          return point_intersects_shape?(right_points.first, left_points)
        end

        left_edges.each do |left_start, left_end|
          right_edges.each do |right_start, right_end|
            return true if segments_intersect?(left_start, left_end, right_start, right_end)
          end
        end

        point_intersects_shape?(left_points.first, right_points) ||
          point_intersects_shape?(right_points.first, left_points)
      end

      def intersects?(source, others)
        Array(others).any? do |other|
          other && intersect?(source, other)
        end
      end

      private

      def world_points(collidable)
        pos = collidable.pos
        offset = collidable.offset
        base_x = pos.x + offset.x
        base_y = pos.y + offset.y

        normalize_points(Array(collidable.shape).map do |point|
          Pos.new(base_x + point.x, base_y + point.y)
        end)
      end

      def normalize_points(points)
        normalized = []

        points.each do |point|
          next unless point

          copy = Pos.new(point.x, point.y)
          next if normalized.any? && same_point?(normalized.last, copy)

          normalized << copy
        end

        if normalized.length > 1 && same_point?(normalized.first, normalized.last)
          normalized.pop
        end

        normalized
      end

      def edges(points)
        case points.length
        when 0, 1
          []
        when 2
          [[points[0], points[1]]]
        else
          segments = []
          points.each_with_index do |point, index|
            segments << [point, points[(index + 1) % points.length]]
          end
          segments
        end
      end

      def point_intersects_shape?(point, points)
        case points.length
        when 0
          false
        when 1
          same_point?(point, points.first)
        when 2
          point_on_segment?(point, points[0], points[1])
        else
          point_on_polygon_boundary?(point, points) || point_inside_polygon?(point, points)
        end
      end

      def point_on_polygon_boundary?(point, points)
        edges(points).any? do |segment_start, segment_end|
          point_on_segment?(point, segment_start, segment_end)
        end
      end

      def point_inside_polygon?(point, points)
        inside = false
        previous = points.last

        points.each do |current|
          if ((current.y > point.y) != (previous.y > point.y))
            cross_x = previous.x + ((point.y - previous.y) * (current.x - previous.x).to_f / (current.y - previous.y))
            inside = !inside if point.x < cross_x
          end

          previous = current
        end

        inside
      end

      def segments_intersect?(a_start, a_end, b_start, b_end)
        ab_start = cross(a_start, a_end, b_start)
        ab_end = cross(a_start, a_end, b_end)
        ba_start = cross(b_start, b_end, a_start)
        ba_end = cross(b_start, b_end, a_end)

        return true if ab_start == 0 && point_on_segment?(b_start, a_start, a_end)
        return true if ab_end == 0 && point_on_segment?(b_end, a_start, a_end)
        return true if ba_start == 0 && point_on_segment?(a_start, b_start, b_end)
        return true if ba_end == 0 && point_on_segment?(a_end, b_start, b_end)

        different_sides?(ab_start, ab_end) && different_sides?(ba_start, ba_end)
      end

      def point_on_segment?(point, segment_start, segment_end)
        return false unless cross(segment_start, segment_end, point) == 0

        min_x = segment_start.x < segment_end.x ? segment_start.x : segment_end.x
        max_x = segment_start.x > segment_end.x ? segment_start.x : segment_end.x
        min_y = segment_start.y < segment_end.y ? segment_start.y : segment_end.y
        max_y = segment_start.y > segment_end.y ? segment_start.y : segment_end.y

        point.x >= min_x && point.x <= max_x && point.y >= min_y && point.y <= max_y
      end

      def different_sides?(left, right)
        (left > 0 && right < 0) || (left < 0 && right > 0)
      end

      def cross(origin, first, second)
        (first.x - origin.x) * (second.y - origin.y) - (first.y - origin.y) * (second.x - origin.x)
      end

      def same_point?(left, right)
        left.x == right.x && left.y == right.y
      end
    end
  end
end