require 'minitest'
require 'byebug'
require 'set'

def Exactly(x)
  lambda do |string|
    letter_counts = Hash.new(0)
    string.chars.each { |char| letter_counts[char] += 1 }
    letter_counts.any? { |letter, count| count == x }
  end
end

def Checksum(strings)
  strings.count(&Exactly(2)) * strings.count(&Exactly(3))
end

def ZipChars(string1, string2)
  string1.chars.zip(string2.chars)
end

def StringDiff(string1, string2)
  ZipChars(string1, string2).select { |c1, c2| c1 != c2 }
end

def CommonSubstring(string1, string2)
  ZipChars(string1, string2).select { |c1, c2| c1 == c2 }.map(&:first).join
end

def OffByOne(strings)
  strings.combination(2).find { |pair| StringDiff(*pair).size == 1 }
end

class Test < Minitest::Test
  def exactly_2
    assert Exactly(2)["abcdef"]
  end

  def test_1
    assert_equal [["b", "x"]], StringDiff("abcd", "axcd")
  end

  def test_2
    assert_equal "acd", CommonSubstring("abcd", "axcd")
  end

  def test_solution_part_1
    input = File.read("day2.input").each_line
    assert_equal 3952, Checksum(input)
  end

  def test_solution_part_2
    input = File.read("day2.input").each_line.to_a
    assert "vtnikorkulbfejvyznqgdxpaw", CommonSubstring(*OffByOne(input))
  end
end

Minitest.autorun
