require "bit_array"

class Screen
  getter width, height

  @pixels : BitArray

  def initialize(@width : UInt32, @height : UInt32)
    @pixels = empty_pixels
  end

  def update
    @pixels = empty_pixels.tap do |new_pixels|
      @height.times.each do |y|
        @width.times.each do |x|
          new_pixels[coordinates_to_index(x, y)] = yield x, y
        end
      end
    end

    self
  end

  def pixels
    @pixels.in_groups_of(@width).to_a
  end

  def [](x, y)
    @pixels[coordinates_to_index(x, y)]
  end

  private def coordinates_to_index(x, y)
    y * @width + x
  end

  private def empty_pixels
    BitArray.new(@width.to_i * @height.to_i)
  end
end

abstract class Instruction
  abstract def perform(pixels : Pixels) : Pixels

  def self.import(instructions : String)
    instructions.each_line.map { |line|
      if line =~ /rect (\d+)x(\d+)/
        Rect.new($~[1].to_u32, $~[2].to_u32)
      elsif line =~ /rotate row y=(\d+) by (\d+)/
        RotateRow.new($~[1].to_u32, $~[2].to_u32)
      elsif line =~ /rotate column x=(\d+) by (\d+)/
        RotateColumn.new($~[1].to_u32, $~[2].to_u32)
      else
        raise "Error parsing instruction: #{line}"
      end
    }
  end

  class Rect < Instruction
    def initialize(@width : UInt32, @height : UInt32)
    end

    def perform(screen)
      screen.update do |x, y|
        x < @width && y < @height ? true : screen[x, y]
      end
    end
  end

  class RotateRow < Instruction
    def initialize(@y : UInt32, @delta : UInt32)
    end

    def perform(screen)
      screen.update do |x, y|
        if y == @y
          screen[(x - @delta) % screen.width, y]
        else
          screen[x, y]
        end
      end
    end
  end

  class RotateColumn < Instruction
    def initialize(@x : UInt32, @delta : UInt32)
    end

    def perform(screen)
      screen.update do |x, y|
        if x == @x
          screen[x, (y - @delta) % screen.height]
        else
          screen[x, y]
        end
      end
    end
  end
end

require "spec"

describe "Day 8" do
  it "lights the expected pixels in the sample" do
    screen = Screen.new(7_u32, 3_u32)

    Instruction
      .import("rect 3x2\nrotate column x=1 by 1\nrotate row y=0 by 4\nrotate column x=1 by 1\n")
      .each(&.perform(screen))

    screen.pixels.should eq(
      [
        [false, true, false, false, true, false, true],
        [true, false, true, false, false, false, false],
        [false, true, false, false, false, false, false]
      ]
    )
  end

  it "counts the number of lit pixels in the challenge input" do
    screen = Screen.new(50_u32, 6_u32)
    Instruction.import(File.read("day8.input")).each(&.perform(screen))

    puts
    screen.pixels.each do |row|
      puts row.map { |v| v ? "X" : "-" }.join
    end

    screen.pixels.flatten.select(&.itself).size.should eq(110)
  end
end
