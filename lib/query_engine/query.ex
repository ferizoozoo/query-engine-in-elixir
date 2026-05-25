defmodule QueryEngine.Query do
  defstruct source: nil,
            select: nil,
            filters: [],
            projections: [],
            limit: nil,
            joins: [],
            group_by: nil,
            order_by: nil,
            aggregations: []

  def from(source) do
    %__MODULE__{source: source}
  end

  def select(query, fields) do
    %{query | select: fields}
  end

  def where(query, condition) do
    %{query | filters: query.filters ++ [condition]}
  end

  def join(query, source, on) do
    %{query | joins: query.joins ++ [%{source: source, on: on}]}
  end

  def group_by(query, fields) do
    %{query | group_by: fields}
  end

  def order_by(query, fields) do
    %{query | order_by: fields}
  end

  def limit(query, count) do
    %{query | limit: count}
  end
end
