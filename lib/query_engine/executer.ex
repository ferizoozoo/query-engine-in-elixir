defmodule QueryEngine.Executor do
  alias QueryEngine.{Query, CSV, Expr}

  def run(%Query{} = query) do
    query.source
    |> load_source()
    |> apply_filters(query.filters)
    |> apply_joins(query.joins)
    |> apply_group_by(query.group_by)
    |> apply_aggregations(query.aggregations)
    |> apply_select(query.select)
    |> apply_order(query.order_by)
    |> apply_limit(query.limit)
  end

  defp load_source(source) do
    case source do
      {:csv, file_path} ->
        CSV.stream(file_path)

      file_path when is_binary(file_path) ->
        cond do
          String.ends_with?(file_path, ".csv") -> CSV.stream(file_path)
          true -> raise "Unsupported source type: #{inspect(source)}"
        end

      _ ->
        raise "Unsupported source type: #{inspect(source)}"
    end
  end

  defp apply_filters(stream, filters) do
    Enum.reduce(filters, stream, fn filter, acc ->
      Stream.filter(acc, &Expr.eval(filter, &1))
    end)
  end

  defp apply_joins(stream, []), do: stream

  defp apply_joins(stream, [join | rest]) do
    index =
      join.source
      |> load_source()
      |> Enum.reduce(%{}, fn row, acc ->
        key = Map.get(row, join.on)
        Map.update(acc, key, [row], &[row | &1])
      end)

    joined =
      Stream.flat_map(stream, fn row ->
        key = Map.get(row, join.on)

        Map.get(index, key, [])
        |> Enum.map(&Map.merge(row, &1))
      end)

    apply_joins(joined, rest)
  end

  defp apply_group_by(stream, _group_by) do
    # For simplicity, we won't implement group by in this example
    stream
  end

  defp apply_aggregations(stream, _aggregations) do
    # For simplicity, we won't implement aggregations in this example
    stream
  end

  defp apply_select(stream, nil), do: stream

  defp apply_select(stream, select) do
    Stream.map(stream, fn row ->
      Map.take(row, select)
    end)
  end

  defp apply_order(stream, nil), do: stream

  defp apply_order(stream, spec) do
    Enum.sort(stream, fn a, b -> order_compare(a, b, spec) end)
  end

  defp apply_limit(stream, nil), do: stream

  defp apply_limit(stream, count) do
    Stream.take(stream, count)
  end

  defp order_compare(_, _, []), do: false

  defp order_compare(a, b, [{col, dir} | rest]) do
    va = Map.get(a, col)
    vb = Map.get(b, col)

    cond do
      va == vb -> order_compare(a, b, rest)
      dir == :asc -> va < vb
      dir == :desc -> va > vb
    end
  end
end
