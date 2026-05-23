defmodule QueryEngine.ExprTest do
  use ExUnit.Case
  alias QueryEngine.Expr

  test "column lookup" do
    assert Expr.eval({:column, "name"}, %{"name" => "Ada"}) == "Ada"
  end

  test "literal" do
    assert Expr.eval({:literal, 42}, %{}) == 42
  end

  test "numeric comparison treats string cells as numbers" do
    row = %{"age" => "36"}
    assert Expr.eval({:>, {:column, "age"}, {:literal, 30}}, row)
    refute Expr.eval({:>, {:column, "age"}, {:literal, 200}}, row)
  end

  test "string comparison" do
    row = %{"name" => "Ada"}
    assert Expr.eval({:=, {:column, "name"}, {:literal, "Ada"}}, row)
    refute Expr.eval({:=, {:column, "name"}, {:literal, "Grace"}}, row)
  end

  test "AND combines two conditions" do
    row = %{"age" => "36", "city" => "London"}

    ast =
      {:and, {:>, {:column, "age"}, {:literal, 30}},
       {:=, {:column, "city"}, {:literal, "London"}}}

    assert Expr.eval(ast, row)
  end

  test "OR is inclusive" do
    row = %{"age" => "20", "city" => "London"}

    ast =
      {:or, {:>, {:column, "age"}, {:literal, 30}}, {:=, {:column, "city"}, {:literal, "London"}}}

    assert Expr.eval(ast, row)
  end

  test "missing column is nil and falsy" do
    row = %{"age" => "36"}
    refute Expr.eval({:column, "missing"}, row)
    refute Expr.eval({:and, {:column, "missing"}, {:literal, true}}, row)
  end
end
