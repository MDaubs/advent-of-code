require 'minitest'
require 'byebug'

class Grid
  def initialize
    @address_to_coordinates = []
    @coordinates_to_address = {}
    @square_enumerator = Enumerator.new do |e|
      stride = 2
      x = 0
      y = 0
      addr = 1

      right = proc { x, y = [x + 1, y] }
      up    = proc { x, y = [x, y + 1] }
      left  = proc { x, y = [x - 1, y] }
      down  = proc { x, y = [x, y - 1] }
      increment = proc { |direction| e << [addr += 1, *direction.()] }

      e << [addr, x, y]

      loop do
        increment.(right)
        (stride - 1).times { increment.(up) }
        stride.times { increment.(left) }
        stride.times { increment.(down) }
        stride.times { increment.(right) }

        stride += 2
      end
    end
  end

  def address(addr)
    ensure_square_cache_loaded_up_to(addr)
    Square.new(addr, @address_to_coordinates[addr - 1])
  end

  def neighboring_sums
    Enumerator.new do |o|
      value_by_address = [1]
      o << 1
      addr = 2

      loop do
        neighbors = address(addr)
          .neighboring_coordinates
          .map { |coords| @coordinates_to_address[coords] }
          .compact
          .select { |neighbor_addr| neighbor_addr < addr }

        neighboring_sum = neighbors
          .map { |neighbor_addr| value_by_address[neighbor_addr - 1] }
          .sum

        o << value_by_address[addr - 1] = neighboring_sum

        addr += 1
      end
    end
  end

  private

  def ensure_square_cache_loaded_up_to(addr)
    while @address_to_coordinates.size < addr
      a, x, y = @square_enumerator.next
      @address_to_coordinates[a - 1] = [x, y]
      @coordinates_to_address[[x, y]] = a
    end

    nil
  end

  class Square < Struct.new(:address, :coordinates, :value)
    def distance_to_origin
      coordinates.map(&:abs).sum
    end

    def neighboring_coordinates
      [
        [x - 1, y + 1], [x, y + 1], [x + 1, y + 1],
        [x - 1, y + 0],             [x + 1, y + 0],
        [x - 1, y - 1], [x, y - 1], [x + 1, y - 1]
      ]
    end

    def x
      coordinates[0]
    end

    def y
      coordinates[1]
    end
  end
end

class TestPart1 < Minitest::Test
  def setup
    @grid = Grid.new
  end

  # Data from square 1 is carried 0 steps, since it's at the access port.
  def test_1
    assert_equal 0, @grid.address(1).distance_to_origin
  end

  # Data from square 12 is carried 3 steps, such as: down, left, left.
  def test_2
    assert_equal 3, @grid.address(12).distance_to_origin
  end

  # Data from square 23 is carried only 2 steps: up twice.
  def test_3
    assert_equal 2, @grid.address(23).distance_to_origin
  end

  # Data from square 1024 must be carried 31 steps.
  def test_4
    assert_equal 31, @grid.address(1024).distance_to_origin
  end
end

class TestPart2 < Minitest::Test
  def setup
    @grid = Grid.new
  end

  # Square 1 starts with the value 1.
  # Square 2 has only one adjacent filled square (with value 1), so it also stores 1.
  # Square 3 has both of the above squares as neighbors and stores the sum of their values, 2.
  # Square 4 has all three of the aforementioned squares as neighbors and stores the sum of their values, 4.
  # Square 5 only has the first and fourth squares as neighbors, so it gets the value 5.
  def test_1
    assert_equal [1, 1, 2, 4, 5], @grid.neighboring_sums.first(5)
  end
end

Minitest.autorun

grid = Grid.new
puts "Solution to part 1: #{grid.address(277678).distance_to_origin}"
puts "Solution to part 2: #{grid.neighboring_sums.find { |s| s > 277678 }}"
