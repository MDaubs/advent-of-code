require 'minitest'
require 'byebug'
require 'strscan'

class Instructions
  def self.parse(string)
    instructions = []
    scanner = StringScanner.new(string)
    until scanner.eos?
      case token = scanner.scan(/\(|\)/)
      when "("
        instructions << Up
      when ")"
        instructions << Down
      else
        raise "Unknown token #{token}"
      end
    end
    new(instructions)

    # new string.each_char.map { |token|
    #   case token
    #   when "("
    #     Up
    #   when ")"
    #     Down
    #   else
    #     raise "Unknown token #{token}"
    #   end
    # }
  end

  def initialize(instructions)
    @instructions = instructions
  end

  def execute
    @instructions.reduce(0) { |fl, i| i.call(fl) }
  end

  Up = ->(fl) { fl + 1 }
  Down = ->(fl) { fl - 1 }
end


class Test < Minitest::Test
  # (()) and ()() both result in floor 0.
  def test_floor_0
    assert_equal 0, Instructions.parse("(())").execute
    assert_equal 0, Instructions.parse("()()").execute
  end

  # ((( and (()(()( both result in floor 3.
  def test_floor_3
    assert_equal 3, Instructions.parse("(((").execute
    assert_equal 3, Instructions.parse("(()(()(").execute
    assert_equal 3, Instructions.parse("))(((((").execute
  end

  # ))((((( also results in floor 3.
  def test_basement
    assert_equal -1, Instructions.parse("())").execute
    assert_equal -1, Instructions.parse("))(").execute
  end

  # ()) and ))( both result in floor -1 (the first basement level).
  # ))) and )())()) both result in floor -3.
  def test_sub_basement
    assert_equal -3, Instructions.parse(")))").execute
    assert_equal -3, Instructions.parse(")())())").execute
  end
end

puts "Solution: #{Instructions.parse(File.read("day1.input").gsub("\n", "")).execute}"

Minitest.autorun
