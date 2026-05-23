defmodule QueryEngine.Expr do
  def eval({:column, name}, row), do: Map.get(row, name)
  def eval({:literal, val}, _row), do: val

  def eval({:and, l, r}, row), do: eval(l, row) && eval(r, row)
  def eval({:or, l, r}, row), do: eval(l, row) || eval(r, row)
  def eval({:not, e}, row), do: !eval(e, row)

  def eval({:=, l, r}, row), do: compare(eval(l, row), eval(r, row)) == :eq
  def eval({:!=, l, r}, row), do: compare(eval(l, row), eval(r, row)) != :eq
  def eval({:>, l, r}, row), do: compare(eval(l, row), eval(r, row)) == :gt
  def eval({:<, l, r}, row), do: compare(eval(l, row), eval(r, row)) == :lt
  def eval({:>=, l, r}, row), do: compare(eval(l, row), eval(r, row)) in [:gt, :eq]
  def eval({:<=, l, r}, row), do: compare(eval(l, row), eval(r, row)) in [:lt, :eq]

  defp compare(a, b) do
    case {to_number(a), to_number(b)} do
      {{:ok, na}, {:ok, nb}} ->
        cond do
          na < nb -> :lt
          na > nb -> :gt
          true -> :eq
        end

      _ ->
        cond do
          a < b -> :lt
          a > b -> :gt
          true -> :eq
        end
    end
  end

  defp to_number(n) when is_number(n), do: {:ok, n}

  defp to_number(s) when is_binary(s) do
    case Float.parse(s) do
      {f, ""} -> {:ok, f}
      _ -> :error
    end
  end

  defp to_number(_), do: :error
end
