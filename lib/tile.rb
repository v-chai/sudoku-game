require "colorize"

class Tile
    attr_reader :given
    attr_accessor :value, :dupe

    def initialize(value)
        @value = value.to_i
        @given = (@value > 0)
        @dupe = false
    end

    def to_s
        if @given
            @value.to_s
        elsif @value == 0
            @value.to_s.light_black
        elsif @dupe 
            @value.to_s.red
        else
            @value.to_s.blue
        end

    end
end