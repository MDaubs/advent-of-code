require "string_scanner"

enum Bearing
  North
  East
  South
  West

  def left
    Bearing.values.rotate(to_i - 1).first
  end

  def right
    Bearing.values.rotate(to_i + 1).first
  end

  def x(x)
    east? ? x+1 : west? ? x-1 : x
  end

  def y(y)
    north? ? y+1 : south? ? y-1 : y
  end

  def dx
    ->(x : Int32) { east? ? x+1 : west? ? x-1 : x }
  end

  def dy
    ->(y : Int32) { north? ? y+1 : south? ? y-1 : y }
  end
end

alias Instruction = State -> State

TurnLeft  = ->(state : State) { state.turn_left }
TurnRight = ->(state : State) { state.turn_right }
Travel    = ->(state : State) { state.travel }

struct Point
  getter x, y

  def initialize(@x : Int32, @y : Int32)
  end

  def delta(dx : Int32 -> Int32, dy : Int32 -> Int32)
    Point.new(dx.call(x), dy.call(y))
  end
end

struct State
  getter point, bearing

  def initialize(@point : Point, @bearing : Bearing)
  end

  def turn_left
    State.new(point, bearing.left)
  end

  def turn_right
    State.new(point, bearing.right)
  end

  def travel
    State.new(point.delta(bearing.dx, bearing.dy), bearing)
  end
end

class Document
  getter instructions

  @instructions = [] of Instruction

  def initialize(sequence : String)
    scanner = StringScanner.new(sequence)

    until scanner.eos?
      scanner.skip(/, /)

      case turn_token = scanner.scan(/[LR]/)
      when "L"
        @instructions << TurnLeft
      when "R"
        @instructions << TurnRight
      else
        raise "Expecting a turn 'L' or 'R' but got '#{turn_token}'."
      end

      if travel_token = scanner.scan(/\d+/)
        travel_token.to_i.times do
          @instructions << Travel
        end
      else
        raise "Expecting a number of blocks to travel but got '#{travel_token}'."
      end
    end
  end
end

class Trip
  @transitions = [] of {State, Instruction, State}

  def initialize(document : Document)
    start_state = State.new(Point.new(0, 0), Bearing::North)

    document.instructions.each do |instruction|
      finish_state = instruction.call(start_state)
      @transitions << {start_state, instruction, finish_state}
      start_state = finish_state
    end
  end

  def current_point
    @transitions.last.not_nil!.last.not_nil!.point
  end

  def distance_from_origin
    current_point.x.abs + current_point.y.abs
  end
end

require "spec"

describe "Day 1" do
  describe "first example" do
    trip = Trip.new(Document.new("R2, L3"))

    it "calculates coordinates correctly" do
      trip.current_point.should eq(Point.new(2, 3))
    end

    it "calculates distance correctly" do
      trip.distance_from_origin.should eq(5)
    end
  end

  describe "second example" do
    trip = Trip.new(Document.new("R2, R2, R2"))

    it "calculates coordinates correctly" do
      trip.current_point.should eq(Point.new(0, -2))
    end

    it "calculates distance correctly" do
      trip.distance_from_origin.should eq(2)
    end
  end

  describe "third example" do
    trip = Trip.new(Document.new("R5, L5, R5, R3"))

    it "calculates distance correctly" do
      trip.distance_from_origin.should eq(12)
    end
  end

  describe "challenge example" do
    trip = Trip.new(Document.new("L1, L5, R1, R3, L4, L5, R5, R1, L2, L2, L3, R4, L2, R3, R1, L2, R5, R3, L4, R4, L3, R3, R3, L2, R1, L3, R2, L1, R4, L2, R4, L4, R5, L3, R1, R1, L1, L3, L2, R1, R3, R2, L1, R4, L4, R2, L189, L4, R5, R3, L1, R47, R4, R1, R3, L3, L3, L2, R70, L1, R4, R185, R5, L4, L5, R4, L1, L4, R5, L3, R2, R3, L5, L3, R5, L1, R5, L4, R1, R2, L2, L5, L2, R4, L3, R5, R1, L5, L4, L3, R4, L3, L4, L1, L5, L5, R5, L5, L2, L1, L2, L4, L1, L2, R3, R1, R1, L2, L5, R2, L3, L5, L4, L2, L1, L2, R3, L1, L4, R3, R3, L2, R5, L1, L3, L3, L3, L5, R5, R1, R2, L3, L2, R4, R1, R1, R3, R4, R3, L3, R3, L5, R2, L2, R4, R5, L4, L3, L1, L5, L1, R1, R2, L1, R3, R4, R5, R2, R3, L2, L1, L5"))

    it "calculates distance correctly" do
      trip.distance_from_origin.should eq(253)
    end
  end
end
