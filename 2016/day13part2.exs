defmodule Location do
  def neighbors({0, 0}), do: [{1, 0}, {0, 1}]
  def neighbors({0, y}), do: [{1, y}, {0, y-1}, {0, y+1}]
  def neighbors({x, 0}), do: [{x-1, 0}, {x+1, 0}, {x, 1}]
  def neighbors({x, y}), do: [{x-1, y}, {x+1, y}, {x, y-1}, {x, y+1}]
end

defmodule World do
  require Integer

  defstruct magic_number: 0, explored_location_types: %{{1, 1} => :open}

  def explore(world = %World{explored_location_types: explored_location_types}) do
    update_explored_location_types = &(Map.put(world, :explored_location_types, &1))

    explored_location_types
    |> Map.keys
    |> Enum.flat_map(&Location.neighbors/1)
    |> Enum.reduce(explored_location_types, fn(location, aggr) -> Map.put_new(aggr, location, location_type(world, location)) end)
    |> update_explored_location_types.()
  end

  defp location_type(%World{magic_number: magic_number}, location = {x, y}) do
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


defmodule Explore do
  def start(magic_number) do
    %World{magic_number: magic_number}
  end
end

world = (1..50) |> Enum.reduce(Explore.start(1352), fn(_, world) -> World.explore(world) end)
IO.puts world.explored_location_types |> Map.values |> Enum.count(&(&1 == :open))
