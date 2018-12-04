require 'minitest'
require 'byebug'
require 'set'
require 'strscan'

def Claim(definition, fabric)
  ss = StringScanner.new(definition)
  ss.skip(/#/)
  id = ss.scan(/\d+/)
  ss.skip(/ @ /)
  left = ss.scan(/\d+/).to_i
  ss.skip(/,/)
  top = ss.scan(/\d+/).to_i
  ss.skip(/: /)
  width = ss.scan(/\d+/).to_i
  ss.skip(/x/)
  height = ss.scan(/\d+/).to_i

  (top...top+height).each do |row|
    (left...left+width).each do |column|
      fabric[row][column] << id
    end
  end
end

def Fabric(dimension)
  Array.new(dimension) { Array.new(dimension) { [] }}
end

def OverlappingCells(fabric)
  fabric.flat_map do |row|
    row.select do |column|
      column.size > 1
    end
  end
end

def AllIds(fabric)
  fabric.flatten.uniq
end

def OverlappingIds(fabric)
  OverlappingCells(fabric).flatten.uniq
end

def ParseEntry(line)
  ss = StringScanner.new(definition)
  # read date
  # read minutes
  # read instruction
  ss.skip(/[\d\d\d\d-\d\d-\d\d \d\d:\d\d] Guard #/)
  guard = ss.scan(/\d+/)
  ss.skip(/ begins /)
  left = ss.scan(/\d+/).to_i
  ss.skip(/,/)
  top = ss.scan(/\d+/).to_i
  ss.skip(/: /)
  width = ss.scan(/\d+/).to_i
  ss.skip(/x/)
  height = ss.scan(/\d+/).to_i

end

def Report(input)
  entries = Hash[input.each_line(&ParseEntry)]
end

class Test < Minitest::Test
  def test_trial
    input =
      %{[1518-11-01 00:00] Guard #10 begins shift
[1518-11-01 00:05] falls asleep
[1518-11-01 00:25] wakes up
[1518-11-01 00:30] falls asleep
[1518-11-01 00:55] wakes up
[1518-11-01 23:58] Guard #99 begins shift
[1518-11-02 00:40] falls asleep
[1518-11-02 00:50] wakes up
[1518-11-03 00:05] Guard #10 begins shift
[1518-11-03 00:24] falls asleep
[1518-11-03 00:29] wakes up
[1518-11-04 00:02] Guard #99 begins shift
[1518-11-04 00:36] falls asleep
[1518-11-04 00:46] wakes up
[1518-11-05 00:03] Guard #99 begins shift
[1518-11-05 00:45] falls asleep
[1518-11-05 00:55] wakes up}

    guards = Report(input)

    assert_equal 50, MinutesAsleep(guards[10])
    assert_equal 30, MinutesAsleep(guards[99])
    assert_equal 24, MostAsleepMinute(guards[10])
  end
end

Minitest.autorun
