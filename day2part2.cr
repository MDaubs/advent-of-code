require "string_scanner"

alias Key = Char

enum Instruction
  MoveUp
  MoveDown
  MoveLeft
  MoveRight
end

struct Instructions
  MAP = {
    'U' => Instruction::MoveUp,
    'D' => Instruction::MoveDown,
    'L' => Instruction::MoveLeft,
    'R' => Instruction::MoveRight
  }

  @lines : Array(Array(Instruction))

  getter lines

  def initialize(encoded : String)
    @lines = encoded.strip.split("\n").map { |line|
      line.chars.map(&->MAP.fetch(Char))
    }
  end
end

class Keypad
  def initialize(@grid : Array(Array(Key)), @instructions : Instructions)
  end

  def code
    starting_key = '5'

    @instructions.lines.map { |line|
      starting_key = line.reduce(starting_key) { |key, instruction|
        case instruction
        when Instruction::MoveUp
          key_above(key)
        when Instruction::MoveDown
          key_below(key)
        when Instruction::MoveLeft
          key_left_of(key)
        else
          key_right_of(key)
        end || key
      }
    }
  end

  def coordinates_of(key : Key)
    @grid.each_with_index do |keys, row|
      keys.each_with_index do |candidate_key, col|
        if candidate_key == key
          return {row, col}
        end
      end
    end

    raise "Keypad does not include #{key}."
  end

  def key_above(key : Key)
    row, col = coordinates_of(key)

    if row == 0
      nil
    else
      @grid[row - 1][col]
    end
  end

  def key_below(key : Key)
    row, col = coordinates_of(key)

    if row == @grid.size - 1
      nil
    else
      @grid[row + 1][col]
    end
  end

  def key_left_of(key : Key)
    row, col = coordinates_of(key)

    if col == 0
      nil
    else
      @grid[row][col - 1]
    end
  end

  def key_right_of(key : Key)
    row, col = coordinates_of(key)

    if col == @grid[row].size - 1
      nil
    else
      @grid[row][col + 1]
    end
  end
end

require "spec"

describe "Day 2" do
  grid = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9']
  ]

  describe "first example" do
    it "produces the correct bathroom code" do
      keypad = Keypad.new(grid, Instructions.new("ULL\nRRDDD\nLURDL\nUUUUD"))
      keypad.code.should eq(['1', '9', '8', '5'])
    end
  end

  describe "challenge example" do
    it "produces the correct bathroom code" do
      keypad = Keypad.new(grid, Instructions.new(File.read("day2.input")))
      keypad.code.should eq(['8', '2', '9', '5', '8'])
    end
  end
end
