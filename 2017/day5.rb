require 'minitest'
require 'byebug'

class Program
  def initialize(jumps)
    @jumps = jumps
  end

  def steps_to_escape
    run { 1 }
  end

  def steps_to_escape2
    run { |offset| offset >= 3 ? -1 : 1 }
  end

  private

  def run(&offset_logic)
    list = @jumps.dup
    index = 0
    count = 0

    while offset = list[index]
      list[index] += offset_logic.(offset)
      index += offset
      count += 1
    end

    count
  end
end

class TestPart1 < Minitest::Test
  def test_example
    assert_equal 5, Program.new([0, 3, 0, 1, -3]).steps_to_escape
  end

  def test_solution
    assert_equal 373543, Program.new(File.new("day5.input").each_line.map(&:to_i)).steps_to_escape
  end
end

class TestPart2 < Minitest::Test
  def test_example
    assert_equal 10, Program.new([0, 3, 0, 1, -3]).steps_to_escape2
  end

  def test_solution
    assert_equal 27502966, Program.new(File.new("day5.input").each_line.map(&:to_i)).steps_to_escape2
  end
end

Minitest.autorun
