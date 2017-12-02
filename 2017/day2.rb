require 'minitest'
require 'byebug'

class Spreadsheet
  attr_reader :rows

  def initialize(input)
    @rows = input.each_line.map do |line|
      Row.new(line)
    end
  end

  def checksum
    rows.map(&:checksum).sum
  end

  def checksum_div
    rows.map(&:checksum_div).sum
  end

  class Row
    def initialize(line)
      @cells = line.gsub("\n", "").split("\t").map(&:to_i)
    end

    def checksum
      @cells.max - @cells.min
    end

    def checksum_div
      a, b = @cells.permutation(2).find { |a, b| a % b == 0 }
      raise "No evenly divisible numbers found in #{@cells}" unless a
      a / b
    end
  end
end

class TestPart1 < Minitest::Test
  # 5 1 9 5
  # 7 5 3
  # 2 4 6 8
  def setup
    @spreadsheet = Spreadsheet.new("5\t1\t9\t5\n7\t5\t3\n2\t4\t6\t8\n")
  end
  #
  #     The first row's largest and smallest values are 9 and 1, and their difference is 8.
  def test_1
    assert_equal 8, @spreadsheet.rows[0].checksum
  end
  #     The second row's largest and smallest values are 7 and 3, and their difference is 4.
  def test_2
    assert_equal 4, @spreadsheet.rows[1].checksum
  end
  #     The third row's difference is 6.
  def test_3
    assert_equal 6, @spreadsheet.rows[2].checksum
  end
  #
  # In this example, the spreadsheet's checksum would be 8 + 4 + 6 = 18.
  def test_4
    assert_equal 18, @spreadsheet.checksum
  end
end

class TestPart2 < Minitest::Test
  # 5 9 2 8
  # 9 4 7 3
  # 3 8 6 5
  def setup
    @spreadsheet = Spreadsheet.new("5\t9\t2\t8\n9\t4\t7\t3\n3\t8\t6\t5\n")
  end
  #
  #     In the first row, the only two numbers that evenly divide are 8 and 2; the result of this division is 4.
  def test_1
    assert_equal 4, @spreadsheet.rows[0].checksum_div
  end
  #     In the second row, the two numbers are 9 and 3; the result is 3.
  def test_2
    assert_equal 3, @spreadsheet.rows[1].checksum_div
  end
  #     In the third row, the result is 2.
  def test_3
    assert_equal 2, @spreadsheet.rows[2].checksum_div
  end
  #
  # In this example, the sum of the results would be 4 + 3 + 2 = 9.
  def test_4
    assert_equal 9, @spreadsheet.checksum_div
  end
end

puts "Solution to part 1: #{Spreadsheet.new(File.read("day2.input")).checksum}"
puts "Solution to part 2: #{Spreadsheet.new(File.read("day2.input")).checksum_div}"

Minitest.autorun
