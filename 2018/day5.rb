require 'minitest'

class MaskedString
  def initialize(string)
    @string = string
    @mask = Array.new(@string.length, false)
  end

  def update_chars(&block)
    (_, i), (_, j) = @string
      .each_char
      .with_index
      .reject { |_, k| @mask[k] }
      .each_cons(2)
      .find { |(a, _), (b, _)| block.(a, b) }

    if i && j
      @mask[i] = @mask[j] = true
    else
      false
    end
  end

  def update_all_chars(&block)
    @string
      .each_char
      .with_index
      .reject { |_, k| @mask[k] }
      .to_a
      .each_cons(2) { |(a, i), (b, j)| @mask[i] = @mask[j] = true if block.(a, b) }
  end

  def to_s
    @string
      .each_char
      .with_index
      .reject { |_, i| @mask[i] }
      .map(&:first)
      .to_a
      .join
  end
end

class Reactor
  def initialize(input)
    @masked_string = MaskedString.new(input)
  end

  def step
    react || react
  end

  def step_all
    react_all || react_all
  end

  def state
    @masked_string.to_s
  end

  private

  def react
    @masked_string.update_chars { |a, b| a.downcase == b.downcase && a != b }
  end

  def react_all
    @masked_string.update_all_chars { |a, b| a.downcase == b.downcase && a != b }
  end
end

class Test < Minitest::Test
  def test_masked_string
    masked_string = MaskedString.new("abcdefgh")
    assert_equal "abcdefgh", masked_string.to_s
    assert masked_string.update_chars { |a, b| a == "d" && b == "e" }
    assert_equal "abcfgh", masked_string.to_s
    refute masked_string.update_chars { |a, b| a == "d" && b == "e" }
    refute masked_string.update_chars { |a, b| a == "c" && b == "g" }
    assert masked_string.update_chars { |a, b| a == "c" && b == "f" }
  end

  def test_reactor_step
    reactor = Reactor.new("dabAcCaCBAcCcaDA")
    assert_equal "dabAcCaCBAcCcaDA", reactor.state
    assert reactor.step
    assert_equal "dabAaCBAcCcaDA", reactor.state
    assert reactor.step
    assert_equal "dabCBAcCcaDA", reactor.state
    assert reactor.step
    assert_equal "dabCBAcaDA", reactor.state
    refute reactor.step
    assert_equal "dabCBAcaDA", reactor.state
  end

  def test_reactor_step_all
    reactor = Reactor.new("dabAcCaCBAcCcaDA")
    assert_equal "dabAcCaCBAcCcaDA", reactor.state
    reactor.step_all
    assert_equal "dabCBAcaDA", reactor.state
  end
end

Minitest.run

reactor = Reactor.new(File.read("day5.input"))

sub_results = {}
reactor.state.chars.map(&:downcase).uniq.each do |unit_to_remove|
  puts "Removing: #{unit_to_remove}"
  sub_reactor = Reactor.new(reactor.state.delete(unit_to_remove))
  while sub_reactor.step
    200.times { sub_reactor.step }
  end
  puts "Result: #{sub_result.length}"
  sub_results[unit_to_remove] = sub_result.length
end

pp sub_results

# while reactor.step
#   200.times { reactor.step }
#   puts "\e[H\e[2J#{reactor.state.length}"
# end

# 9386 is the answer
