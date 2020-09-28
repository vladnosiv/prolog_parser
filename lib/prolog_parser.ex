defmodule PrologParser do
  @moduledoc """
  Documentation for `PrologParser`.
  """

  def checkSyntax(defString) do

    {:ok, tokens, _} = defString |> String.to_charlist |> :lexer.string

    tokens

  end

  


end
