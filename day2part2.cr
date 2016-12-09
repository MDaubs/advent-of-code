require "string_scanner"

alias Key = UInt8
alias Instruction = Key -> Key

MoveUp    = ->(key : Key) { key <= 3 ? key : key - 3 }
MoveDown  = ->(key : Key) { key >= 7 ? key : key + 3 }
MoveLeft  = ->(key : Key) { key % 3 == 1 ? key : key - 1 }
MoveRight = ->(key : Key) { key % 3 == 0 ? key : key + 1 }

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
    starting_key = 5.to_u8

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
    figure_out.the_code.should eq([1, 9, 8, 5])
  end
end

describe "challenge example" do
  it "produces the correct bathroom code" do
    figure_out = FigureOut.new(Instructions.new(File.read("day2.input")))
    figure_out.the_code.should eq([8, 2, 9, 5, 8])
  end
end
