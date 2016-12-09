require "string_scanner"

enum Key
  One   = 1
  Two   = 2
  Three = 3
  Four  = 4
  Five  = 5
  Six   = 6
  Seven = 7
  Eight = 8
  Nine  = 9
end

alias Instruction = Key -> Key

MoveUp    = ->(key : Key) { key.value <= 3 ? key : Key.from_value(key.value - 3) }
MoveDown  = ->(key : Key) { key.value >= 7 ? key : Key.from_value(key.value + 3) }
MoveLeft  = ->(key : Key) { key.value % 3 == 1 ? key : Key.from_value(key.value - 1) }
MoveRight = ->(key : Key) { key.value % 3 == 0 ? key : Key.from_value(key.value + 1) }

struct Instructions
  MAP = {
    'U' => MoveUp,
    'D' => MoveDown,
    'L' => MoveLeft,
    'R' => MoveRight
  }

  @lines : Array(Array(Instruction))

  getter lines

  def initialize(encoded : String)
    @lines = encoded.strip.split("\n").map { |line|
      line.chars.map(&->MAP.fetch(Char))
    }
  end
end

class FigureOut
  def initialize(@instructions : Instructions)
  end

  def the_code
    starting_key = Key::Five

    @instructions.lines.map { |line|
      starting_key = line.reduce(starting_key) { |key, instruction|
        instruction.call(key)
      }
    }
  end
end

require "spec"

describe "first example" do
  it "produces the correct bathroom code" do
    figure_out = FigureOut.new(Instructions.new("ULL\nRRDDD\nLURDL\nUUUUD"))
    figure_out.the_code.should eq([Key::One, Key::Nine, Key::Eight, Key::Five])
  end
end

describe "challenge example" do
  it "produces the correct bathroom code" do
    figure_out = FigureOut.new(Instructions.new(File.read("day2.input")))
    figure_out.the_code.should eq([Key::Eight, Key::Two, Key::Nine, Key::Five, Key::Eight])
  end
end
