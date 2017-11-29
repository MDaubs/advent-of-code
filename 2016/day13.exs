defmodule Office do
  require Integer

  def type_at(x, y, magic_number) do
    if (x*x + 3*x + 2*x*y + y + y*y + magic_number) |> count_bits |> Integer.is_even do
      :open
    else
      :wall
    end
  end

  defp count_bits(integer) do
    for(<<bit::1 <- :binary.encode_unsigned(integer)>>, do: bit) |> Enum.sum
  end
end

defmodule PathSearch do
  def find_shortest(magic_number, x, y, initial_paths, depth_of_paths \\ 0) do
    paths_at_depth = PathSearch.grow_paths(magic_number, initial_paths)

    if Enum.any?(paths_at_depth, fn([most_recent_coordinate | _]) -> most_recent_coordinate == {x, y} end) do
      depth_of_paths + 1
    else
      find_shortest(magic_number, x, y, paths_at_depth, depth_of_paths + 1)
    end
  end

  def grow_paths(magic_number, paths) do
    paths
    |> Enum.flat_map(fn(path = [{x1, y1} | _rest]) ->
      Enum.map allowed_steps_from(magic_number, x1, y1), fn({x2, y2}) ->
        [{x2, y2} | path]
      end
    end)
    |> Enum.filter(fn([most_recent_coordinate | previous_coordinates]) ->
      !Enum.member?(previous_coordinates, most_recent_coordinate)
    end)
  end

  def allowed_steps_from(magic_number, x, y) do
    [{x, y-1}, {x-1, y}, {x+1, y}, {x, y+1}]
    |> Enum.filter(fn({x, y}) -> x > 0 && y > 0 end)
    |> Enum.filter(fn({x, y}) -> Office.type_at(x, y, magic_number) == :open end)
  end
end

IO.puts "  0123456789"
for y <- 0..6 do
  IO.write "#{y} "
  for x <- 0..9 do
    case Office.type_at(x, y, 10) do
      :open -> IO.write "."
      :wall -> IO.write "#"
    end
  end
  IO.write "\n"
end

IO.puts "\nSteps allowed from 1, 1:"
IO.inspect PathSearch.allowed_steps_from(10, 1, 1)

IO.puts "\nDepth 1 paths from 1, 1:"
IO.inspect PathSearch.grow_paths(10, [[{1, 1}]])

IO.puts "\nDepth 2 paths from 1, 1:"
IO.inspect (1..2) |> Enum.reduce([[{1, 1}]], fn(_, acc) -> PathSearch.grow_paths(10, acc) end)

IO.puts "\nDepth 3 paths from 1, 1:"
IO.inspect (1..3) |> Enum.reduce([[{1, 1}]], fn(_, acc) -> PathSearch.grow_paths(10, acc) end)

IO.puts "\nDepth 4 paths from 1, 1:"
IO.inspect (1..4) |> Enum.reduce([[{1, 1}]], fn(_, acc) -> PathSearch.grow_paths(10, acc) end)

steps = PathSearch.find_shortest(10, 7, 4, [[{1, 1}]])
IO.puts "Shortest path from 1,1 to 7,4 is #{steps} steps."

IO.puts "Challenge input:"
steps = PathSearch.find_shortest(1352, 31, 39, [[{1, 1}]])
IO.puts "Shortest path from 1,1 to 7,4 is #{steps} steps."

paths_after_50 = (1..50) |> Enum.reduce([[{1, 1}]], fn(_, acc) -> PathSearch.grow_paths(1352, acc) end)
IO.inspect paths_after_50 |> List.flatten |> Enum.uniq |> length
