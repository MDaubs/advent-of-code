defmodule Instructions do
  def lookup(["cpy", integer, to_register]) when is_integer(integer) do
    fn {registers, i} ->
      {%{registers | to_register => integer}, i + 1}
    end
  end

  def lookup(["cpy", from_register, to_register]) do
    fn {registers, i} ->
      {%{registers | to_register => registers[from_register]}, i + 1}
    end
  end

  def lookup(["inc", register]) do
    fn {registers, i} ->
      {%{registers | register => registers[register] + 1}, i + 1}
    end
  end

  def lookup(["dec", register]) do
    fn {registers, i} ->
      {%{registers | register => registers[register] - 1}, i + 1}
    end
  end

  def lookup(["jnz", register, distance]) do
    fn {registers, i} ->
      delta = if registers[register] != 0 do
        distance
      else
        1
      end

      {registers, i + delta}
    end
  end

  def lookup(instructions) do
    raise "Unable to compile: #{Enum.join(instructions, " ")}"
  end
end

defmodule Eval do
  def run(program, state = {_, i}) when i >= tuple_size(program), do: state
  def run(program, state = {_, i}), do: run(program, elem(program, i).(state))
end

attempt_to_integer = fn val ->
  case Integer.parse(val) do
    {ival, _} -> ival
    :error -> val
  end
end

initial_state = {%{"a" => 0, "b" => 0, "c" => 1, "d" => 0}, 0}

final_state = File.read!("day12.input")
              |> String.split("\n", trim: true)
              |> Enum.map(&(String.split(&1, " ")))
              |> Enum.map(&(Enum.map(&1, attempt_to_integer)))
              |> Enum.map(&Instructions.lookup/1)
              |> List.to_tuple
              |> Eval.run(initial_state)

IO.inspect final_state
