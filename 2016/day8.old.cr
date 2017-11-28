require "bit_array"

alias Pixels = Array(BitArray)

class Screen
  getter pixels

  @pixels : Pixels

  def initialize(width : UInt32, height : UInt32, instructions : Enumerable(Instruction))
    @pixels = instructions.reduce(Pixels.new(height) { BitArray.new(width.to_i) }) { |pixels, instruction| instruction.perform(pixels) }
  end
end

abstract class Instruction
  abstract def perform(pixels : Pixels) : Pixels

  def self.import(instructions : String)
    instructions.each_line.map { |line|
      case line
      when /rect \d+x\d+/
        Rect.new($1.to_i, $2.to_i)
      when /rotate row x=\d+ by \d+/
        RotateRow.new($1.to_i, $2.to_i)
      when /rotate column y=\d+ by \d+/
        RotateColumn.new($1.to_i, $2.to_i)
      else
        raise "Error parsing instruction: #{line}"
      end
    }
  end

  class Rect < Instruction
    def initialize(x, y)
    end

    def perform(pixels)
      pixels
    end
  end

  class RotateRow < Instruction
    def initialize(x, delta)
    end

    def perform(pixels)
      pixels
    end
  end

  class RotateColumn < Instruction
    def initialize(y, delta)
    end

    def perform(pixels)
      pixels
    end
  end
end

require "spec"

describe "Day 8" do
  it "lights the expected pixels" do
    Screen
      .new(7_u32, 3_u32, Instruction.import("rect 3x2\nrotate row x=1 by 1\nrotate row y=0 by 4\n"))
      .pixels.map(&.to_a).should eq(
        [
          [false, true, false, false, true, false, true],
          [true, false, true, false, false, false, false],
          [false, true, false, false, false, false, false]
        ]
      )
  end
end
