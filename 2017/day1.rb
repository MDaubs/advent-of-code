require 'minitest'
require 'byebug'

class Captcha
  def initialize(input)
    @input = input.gsub("\n", "").each_char.map(&:to_i)
  end

  def sum
    sum_of_matching_pairs(each_plus(1))
  end

  def sum2
    sum_of_matching_pairs(each_plus(@input.size / 2))
  end

  private

  def sum_of_matching_pairs(integers)
    integers.reduce(0) { |sum, (a, b)| a == b ? sum + a : sum }
  end

  def each_plus(delta)
    @input.zip(@input.rotate(delta))
  end
end


class TestPart1 < Minitest::Test
  # 1122 produces a sum of 3 (1 + 2) because the first digit (1) matches the second digit and the third digit (2) matches the fourth digit.
  def test_1
    assert_equal 3, Captcha.new("1122").sum
  end

  # 1111 produces 4 because each digit (all 1) matches the next.
  def test_2
    assert_equal 4, Captcha.new("1111").sum
  end

  # 1234 produces 0 because no digit matches the next.
  def test_3
    assert_equal 0, Captcha.new("1234").sum
  end

  # 91212129 produces 9 because the only digit that matches the next one is the last digit, 9.
  def test_4
    assert_equal 9, Captcha.new("91212129").sum
  end
end

class TestPart2 < Minitest::Test
  # 1212 produces 6: the list contains 4 items, and all four digits match the digit 2 items ahead.
  def test_1
    assert_equal 6, Captcha.new("1212").sum2
  end

  # 1221 produces 0, because every comparison is between a 1 and a 2.
  def test_2
    assert_equal 0, Captcha.new("1221").sum2
  end

  # 123425 produces 4, because both 2s match each other, but no other digit has a match.
  def test_3
    assert_equal 4, Captcha.new("123425").sum2
  end

  # 123123 produces 12.
  def test_4
    assert_equal 12, Captcha.new("123123").sum2
  end

  # 12131415 produces 4
  def test_5
    assert_equal 4, Captcha.new("12131415").sum2
  end
end

puts "Solution to part 1: #{Captcha.new(File.read("day1.input").gsub("\n", "")).sum}"
puts "Solution to part 2: #{Captcha.new(File.read("day1.input").gsub("\n", "")).sum2}"

Minitest.autorun
