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

class Test < Minitest::Test
  def test_trial
    input =[
      "#1 @ 1,3: 4x4",
      "#2 @ 3,1: 4x4",
      "#3 @ 5,5: 2x2"
    ]

    fabric = Fabric(10)
    input.each do |s| Claim(s, fabric) end

    assert_equal 4, OverlappingCells(fabric).size
  end

  def test_real_1
    input = File.read("day3.input").lines
    fabric = Fabric(1000)
    input.each do |s| Claim(s, fabric) end

    assert_equal 100261, OverlappingCells(fabric).size
  end

  def test_real_2
    input = File.read("day3.input").lines
    fabric = Fabric(1000)
    input.each do |s| Claim(s, fabric) end
    assert_equal ["251"], AllIds(fabric) - OverlappingIds(fabric)
  end
end

Minitest.autorun
