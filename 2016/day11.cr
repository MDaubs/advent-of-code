struct Microchip
  getter element

  def initialize(@element : Char)
  end

  def to_s
    "#{@element}M"
  end
end

struct Generator
  getter element

  def initialize(@element : Char)
  end

  def to_s
    "#{@element}G"
  end
end

alias Item = Microchip | Generator

class State
  @@cache = {} of State => Array(State)

  getter elevator_floor, item_floors

  def initialize(@elevator_floor : Int32, @item_floors : Hash(Item, Int32))
  end

  def ==(other)
    elevator_floor == other.elevator_floor && item_floors == other.item_floors
  end

  def hash
    elevator_floor.hash * item_floors.hash
  end

  def valid?
    # A state is valid if every floor that contains at least one RTG also
    # contains a matching RTG for each microchip on that floor.

    (1..4).each do |floor|
      items = items_on_floor(floor)

      if items.any?(&.is_a?(Generator))
        gen_elements = items.select(&.is_a?(Generator)).map(&.element)
        chip_elements = items.select(&.is_a?(Microchip)).map(&.element)

        if chip_elements.any? { |chip_element| !gen_elements.includes?(chip_element) }
          return false
        end
      end
    end

    true
  end

  def self.cache_size
    @@cache.size
  end

  def next
    @@cache[self] ||= Array(State).new.tap do |states|
      # If the elevator is on floors 1-3 then try moving one or two items up
      if @elevator_floor < 4
        # One item
        states.concat items_on_floor(@elevator_floor)
          .map { |item| State.new(@elevator_floor + 1, @item_floors.merge({item => @elevator_floor + 1})) }
          .select(&.valid?)

        # Two items
        states.concat items_on_floor(@elevator_floor)
          .each_combination(2)
          .map { |(item1, item2)| @item_floors.merge({item1 => @elevator_floor + 1, item2 => @elevator_floor + 1}) }
          .map { |item_floors| State.new(@elevator_floor + 1, item_floors) }
          .select(&.valid?)
      end

      # If the elevator is on floors 2-4 then try moving one or two items down
      if @elevator_floor > 1
        # One item
        states.concat items_on_floor(@elevator_floor)
          .map { |item| State.new(@elevator_floor - 1, @item_floors.merge({item => @elevator_floor - 1})) }
          .select(&.valid?)

        # Two items
        states.concat items_on_floor(@elevator_floor)
          .each_combination(2)
          .map { |(item1, item2)| @item_floors.merge({item1 => @elevator_floor - 1, item2 => @elevator_floor - 1}) }
          .map { |item_floors| State.new(@elevator_floor - 1, item_floors) }
          .select(&.valid?)
      end
    end
  end

  private def items_on_floor(floor)
    @item_floors.select { |item, item_floor| item_floor == floor }.map(&.first)
  end

  def to_s(io : IO)
    sorted_items = @item_floors.keys.sort_by(&.to_s)

    (1..4).to_a.reverse.each do |floor|
      io << "F#{floor}"

      if @elevator_floor == floor
        io << " E"
      else
        io << "  "
      end

      sorted_items.each do |item|
        if items_on_floor(floor).includes?(item)
          io << " #{item.to_s}"
        else
          io << " . "
        end
      end

      io << "\n"
    end
  end
end

class Solver
  def initialize(@initial_state : State)
  end

  def quickest_solution(desired_state)
    states_to_search = Set(State).new([@initial_state])
    depth = 0

    until states_to_search.empty?
      puts "Searching depth #{depth} size #{states_to_search.size} (#{State.cache_size} cached)"

      if states_to_search.includes?(desired_state)
        return depth
      else
        puts "A"
        states_to_search = states_to_search.each_with_object(Set(State).new(states_to_search.size)) do |state, states|
          states.merge!(state.next)
        end
        depth += 1
        puts "B"
      end
    end
  end
end

Hydrogen  = 'H'
Lithium   = 'L'

puts "Initial:"
puts initial_state = State.new(
  1,
  {
    Microchip.new(Hydrogen) => 1,
    Microchip.new(Lithium) => 1,
    Generator.new(Hydrogen) => 2,
    Generator.new(Lithium) => 3
  }
)

puts "Final:"
puts final_state = State.new(
  4,
  {
    Microchip.new(Hydrogen) => 4,
    Microchip.new(Lithium) => 4,
    Generator.new(Hydrogen) => 4,
    Generator.new(Lithium) => 4
  }
)

initial_state.next.each do |s|
  puts "First step:"
  puts s

  s.next.each do |t|
    puts "Second step:"
    puts t
  end
end

solution = Solver.new(initial_state).quickest_solution(final_state).not_nil!
puts "Solution found at depth #{solution}"

Strontium = 'S'
Plutonium = 'P'
Thulium = 'T'
Ruthenium = 'R'
Curium = 'C'

puts "Initial:"
puts initial_state = State.new(
  1,
  {
    Generator.new(Strontium) => 1,
    Microchip.new(Strontium) => 1,
    Generator.new(Plutonium) => 1,
    Microchip.new(Plutonium) => 1,
    Generator.new(Thulium) => 2,
    Generator.new(Ruthenium) => 2,
    Microchip.new(Ruthenium) => 2,
    Generator.new(Curium) => 2,
    Microchip.new(Curium) => 2,
    Microchip.new(Thulium) => 3
  }
)

puts "Final:"
puts final_state = State.new(
  4,
  {
    Generator.new(Strontium) => 4,
    Microchip.new(Strontium) => 4,
    Generator.new(Plutonium) => 4,
    Microchip.new(Plutonium) => 4,
    Generator.new(Thulium) => 4,
    Generator.new(Ruthenium) => 4,
    Microchip.new(Ruthenium) => 4,
    Generator.new(Curium) => 4,
    Microchip.new(Curium) => 4,
    Microchip.new(Thulium) => 4
  }
)
solution = Solver.new(initial_state).quickest_solution(final_state).not_nil!
puts "Solution found at depth #{solution}"
