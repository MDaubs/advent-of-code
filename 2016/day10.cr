require "spec"

struct Input
  def initialize(@microchip : Microchip, @destination : Bot)
  end

  def execute
    @destination.receive(@microchip)

    self
  end
end

abstract class Node
  abstract def receive(chip : Microchip)
end

alias ComparisonNotification = {Bot, Array(UInt8)}

class Bot < Node
  @low_destination : Node?
  @high_destination : Node?
  @holding_chip : Microchip?

  getter id
  property low_destination, high_destination

  def initialize(@id : UInt8)
  end

  def on_compare(&handler : ComparisonNotification -> Nil)
    @on_compare = handler

    self
  end

  def receive(chip : Microchip)
    raise "Bot #{@id} refuses to receive a chip before both destinations are set" unless @low_destination && @high_destination

    if @holding_chip
      @on_compare.not_nil!.call({self, [@holding_chip.not_nil!, chip].map(&.value).sort})

      if chip.value > @holding_chip.not_nil!.value
        low_destination.not_nil!.receive(@holding_chip.not_nil!)
        high_destination.not_nil!.receive(chip)
        @holding_chip = nil
      else
        low_destination.not_nil!.receive(chip)
        high_destination.not_nil!.receive(@holding_chip.not_nil!)
        @holding_chip = nil
      end
    else
      @holding_chip = chip
    end

    self
  end
end

class Output < Node
  getter holding_chips

  @holding_chips = [] of Microchip

  def initialize(@id : UInt8)
  end

  def receive(chip : Microchip)
    @holding_chips << chip
  end
end

class Microchip
  getter value

  def initialize(@value : UInt8)
  end
end

class World
  @comparisons = [] of ComparisonNotification
  @inputs = [] of Input
  @nodes = {} of String => Node

  getter comparisons

  def add_rules(rules : String)
    rules.strip.each_line.map(&.strip).each do |rule|
      if rule =~ /^value (\d+) goes to (bot \d+)$/
        @inputs << Input.new(Microchip.new($~[1].to_u8), node($~[2]).as(Bot))
      elsif rule =~ /^(bot \d+) gives low to ((?:(?:bot)|(?:output)) \d+) and high to ((?:(?:bot)|(?:output)) \d+)$/
        node($~[1]).as(Bot).tap do |source|
          if source.low_destination
            raise "Bot #{source.id} already has a low destination set"
          else
            source.low_destination = node($~[2])
          end

          if source.high_destination
            raise "Bot #{source.id} already has a high destination set"
          else
            source.high_destination = node($~[3])
          end
        end
      else
        raise "Unable to parse \"#{rule}\""
      end
    end

    self
  end

  def execute
    @inputs.each(&.execute)

    self
  end

  def node(name : String)
    @nodes[name] ||= begin
                       type, id = name.split(" ")

                       case type
                       when "bot"
                         Bot.new(id.to_u8).on_compare { |s| @comparisons << s; nil }
                       when "output"
                         Output.new(id.to_u8)
                       else
                         raise "Unable to parse node name \"#{name}\""
                       end
                     end
  end
end

describe "Day 10" do
  it "validates the sample for part 1" do
    rules = %{
      value 5 goes to bot 2
      bot 2 gives low to bot 1 and high to bot 0
      value 3 goes to bot 1
      bot 1 gives low to output 1 and high to bot 0
      bot 0 gives low to output 2 and high to output 0
      value 2 goes to bot 2
    }

    World
      .new
      .add_rules(rules)
      .execute
      .comparisons
      .find { |bot, values| values == [2, 5] }
      .not_nil!
      .first
      .id
      .should eq(2)
  end

  it "determines which bot compares 17 and 61" do
    World
      .new
      .add_rules(File.read("day10.input"))
      .execute
      .comparisons
      .find { |bot, values| values == [17, 61] }
      .not_nil!
      .first
      .id
      .should eq(47)
  end

  it "determines which values are in which outputs" do
    world = World
      .new
      .add_rules(File.read("day10.input"))
      .execute

    ["output 0", "output 1", "output 2"]
      .map { |name| world.node(name) }
      .map(&.as(Output))
      .flat_map(&.holding_chips)
      .map(&.value)
      .map(&.to_u32)
      .product
      .should eq(-1)
  end
end
