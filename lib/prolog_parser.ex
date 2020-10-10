defmodule PrologParser do
  @moduledoc """
  Documentation for `PrologParser`.
  """
  defp handle_def([def_s]) do
    try do
      {:ok, tokens, _} = def_s |> String.to_charlist |> :lexer.string
      case tokens do
        [] -> {:ok, []}
        _  -> {:error, []}
      end
    rescue
      _ -> :error
    end
  end
  defp handle_def([def_s | defs]) do
    try do
      {:ok, tokens, _} = def_s |> Kernel.<>(".") |> String.to_charlist |> :lexer.string
      {:ok, res1} = :parser.parse(tokens)
      {:ok, res2} = handle_def(defs)
      {:ok, [res1] ++ res2}
    rescue
      _ -> :error
    end
  end

  @spec parse(String.t()) :: atom
  def parse(def_string) do

    defs = String.split(def_string, ".")
    case handle_def(defs) do
      {:ok, res}   -> res
      _            -> "Incorrect Prolog definition."
    end
  end
end
