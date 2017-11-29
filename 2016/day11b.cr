# Structure for transitions? Bit fields for O(1) ops?
# Compute potential transitions given two floor states?
# Indexed by element...
# a. FL1 gens                  : 001010
# b. FL1 chips                 : 010010
# c. Computed pairs (a&b)      : 000010
# d. Computed unpaired (a^b)   : 011000
# e. Computed unshielded (a&d) : 001000

enum ElementFloorState
  None
  Generator
  Microchip
  PoweredPair
end

struct State
  @elevator = 0
  @floors   = StaticArray(Int32, 4).new(0)

  getter elevator

  def initialize(@elevator : Int32, *pair_of_item_floors : Tuple(Int32, Int32))
    pair_of_item_floors.each_with_index do |(gen_floor, chip_floor), index|
      @floors[gen_floor] |= ElementFloorState::Generator.to_u32 << (index * 2)
      @floors[chip_floor] |= ElementFloorState::Microchip.to_u32 << (index * 2)
    end
  end

  def element_on_floor(index, floor)
    ElementFloorState.new((@floors[floor] >> (index * 2)) & 0b11)
  end

  def inspect(*element_chars : Char)
    @floors.each_with_index.to_a.reverse.each do |floor_state, floor_index|
      print "F#{floor_index + 1} #{elevator == floor_index ? "E " : ". "} "

      element_chars.each_with_index do |element, index|
        case element_on_floor(index, floor_index)
        when ElementFloorState::None
          print " .  . "
        when ElementFloorState::Generator
          print " #{element}G . "
        when ElementFloorState::Microchip
          print " .  #{element}M"
        when ElementFloorState::PoweredPair
          print " #{element}G #{element}M"
        end
      end

      puts
    end
  end

  def potential_transitions
    # Consider moving item(s) up.
    # - If floor above has radiation (generator(s) without corresponding chip)
    #   - If floor above has one unpaired RTG with a compatible chip on the
    #     current floor:
    #     - Consider moving the compatible chip up and nothing else.
    #     - Consider moving the compatible chip up and another generator.
    #     - Consider moving the compatible chip up and another chip.
    #   - If floor above has two unpaired RTGs with both compatible chips on the
    #     current floor:
    #     - Consider moving both chips up.
    #   - If floor above has three or more unpaired RTGs:
    #     - Consider moving one RTG and its compatible microchip up.
    #     - Consider moving one or two RTGs up.
    # - Otherwise floor has no radiation (all matching pairs or no RTGs)
    #   - Consider moving one chip up.
    #   - Consider moving two chips up.
    #   - Consider moving a pair up.
    #   - Consider moving one RTG up to complete a pair above.
    #   - Consider moving two RTGs up to complete two pairs above.
    #   - If there are no unpaired chips:
    #     - Consider moving one or two RTGs up that don't complete a pair.

    # Move one generator up
    # Move two generators up
    # Move one generator and one microchip up
    # Move two microchips up
    # Move one generator down
    # Move two generators down
    # Move one generator and one microchip down
    # Move two microchips down
  end
end

# F4 .  .  .  .  .
# F3 .  .  .  LG .
# F2 .  HG .  .  .
# F1 E  .  HM .  LM

elements = {'H', 'L'}
initial_state = State.new(0, {1, 0}, {2, 0})
initial_state.inspect(*elements)
#initial_state.possible_next_states.each(&.inspect(*elements))
