require 'minitest'
require 'set'
require 'byebug'

class Passphrase
  def initialize(string_of_words)
    @words = string_of_words.split(" ")
  end

  def valid?
    @words.uniq.size == @words.size
  end

  def valid2?
    @words.map(&:chars).map(&:sort).uniq.size == @words.size
  end
end

class TestPart1 < Minitest::Test
  # aa bb cc dd ee is valid.
  def test_1
    assert Passphrase.new("aa bb cc dd ee").valid?
  end

  # aa bb cc dd aa is not valid - the word aa appears more than once.
  def test_2
    refute Passphrase.new("aa bb cc dd aa").valid?
  end

  # aa bb cc dd aaa is valid - aa and aaa count as different words.
  def test_3
    assert Passphrase.new("aa bb cc dd aaa").valid?
  end
end

class TestPart2 < Minitest::Test
  # abcde fghij is a valid passphrase.
  def test_1
    assert Passphrase.new("abcde fghij").valid2?
  end

  # abcde xyz ecdab is not valid - the letters from the third word can be rearranged to form the first word.
  def test_2
    refute Passphrase.new("abcde xyz ecdab").valid2?
  end

  # a ab abc abd abf abj is a valid passphrase, because all letters need to be used when forming another word.
  def test_3
    assert Passphrase.new("a ab abc abd abf abj").valid2?
  end

  # iiii oiii ooii oooi oooo is valid.
  def test_4
    assert Passphrase.new("iii oiii ooii oooi oooo").valid2?
  end

  # oiii ioii iioi iiio is not valid - any of these words can be rearranged to form any other word.
  def test_5
    refute Passphrase.new("oiii ioii iioi iiio").valid2?
  end
end

Minitest.autorun

puts "Solution to part 1: #{File.new("day4.input").each_line.map { |line| Passphrase.new(line) }.count(&:valid?)}"
puts "Solution to part 2: #{File.new("day4.input").each_line.map { |line| Passphrase.new(line) }.count(&:valid2?)}"
