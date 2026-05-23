defmodule QueryEngine.CSV do
  def stream(file_path) do
    [header_line | _] = file_path |> File.stream!() |> Enum.take(1)
    headers = header_line |> String.trim() |> parse_line()

    file_path
    |> File.stream!()
    |> Stream.drop(1)
    |> Stream.map(&String.trim/1)
    |> Stream.reject(&(&1 == ""))
    |> Stream.map(&parse_line/1)
    |> Stream.map(&Enum.zip(headers, &1))
    |> Stream.map(&Map.new/1)
  end

  def parse_line(line) do
    parse(line, :field, "", [])
  end

  defp parse("", _state, field, acc), do: [field | acc]

  defp parse(<<"\"\"", rest::binary>>, :quoted, field, acc) do
    parse(rest, :quoted, <<field::binary, "\"">>, acc)
  end

  defp parse(<<"\"", rest::binary>>, :quoted, field, acc) do
    parse(rest, :field, field, acc)
  end

  defp parse(<<"\"", rest::binary>>, :field, "", acc) do
    parse(rest, :quoted, "", acc)
  end

  defp parse(<<",", rest::binary>>, :field, field, acc) do
    parse(rest, :field, "", [field | acc])
  end

  defp parse(<<char, rest::binary>>, state, field, acc) do
    parse(rest, state, <<field::binary, char>>, acc)
  end
end
