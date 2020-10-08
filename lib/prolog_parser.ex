defmodule PrologParser do
  @moduledoc """
  Documentation for `PrologParser`.
  """


  @spec go_next(list, atom) :: atom
  defp go_next([], :end) do :ok end
  defp go_next([], _needle) do :error end
  defp go_next(_tokens, :end) do :error end

  defp go_next([head | tokens], :head) do
    case head do
      :identifier -> go_next(tokens, :corkscrew)
      _           -> :error
    end
  end

  defp go_next([head | tokens], :corkscrew) do
    case head do
      :sep -> go_next(tokens, :identifier)
      :dot -> go_next(tokens, :end)
      _    -> :error
    end
  end

  defp go_next([head | tokens], :identifier) do
    
    recursive_go_into_parentheses = fn tokens ->
      
      get_rparen_index = fn tokens ->
        transformed = Enum.map(tokens, (fn token ->
          case token do
            :lparen -> 1
            :rparen -> (-1)
            _       -> 0
          end
        end))
        
        {balances, _} = :lists.mapfoldl((fn (x, sum) ->
          {x + sum, x + sum}
        end), 0, transformed)

        Enum.find_index(balances, (fn x -> x == (-1) end))
      end

      rparen_index = get_rparen_index.(tokens)
      {left, right} = Enum.split(tokens, 1 + rparen_index)
      left = left |> Enum.reverse() |> tl() |> Enum.reverse() |> Kernel.++([:dot])
      case {go_next(left, :identifier), go_next(right, :operator)} do
        {:error, _} -> :error
        {_, :error} -> :error
        _           -> :ok
      end
    end

    case head do
      :identifier -> go_next(tokens, :operator)
      :lparen     -> recursive_go_into_parentheses.(tokens)
      _           -> :error
    end
  end


  defp go_next([head | tokens], :operator) do
    case head do
      :dot    -> go_next(tokens, :end)
      :comma  -> go_next(tokens, :identifier)
      :disj   -> go_next(tokens, :identifier)
      _       -> :error
    end
  end

  defp parse_lexems(tokens) do
    try do
      go_next(tokens, :head)
    rescue
      _ -> :error
    end
  end

  defp handle_def([def_s]) do
    try do
      {:ok, tokens, _} = def_s |> String.to_charlist |> :lexer.string
      case tokens do
        [] -> :ok
        _  -> :error
      end
    rescue
      _ -> :error
    end
  end
  defp handle_def([def_s | defs]) do
    try do
      {:ok, tokens, _} = def_s |> Kernel.<>(".") |> String.to_charlist |> :lexer.string
      :ok = parse_lexems(tokens)
      :ok = handle_def(defs)
    rescue
      _ -> :error
    end
  end

  @spec check_syntax(String.t()) :: atom
  def check_syntax(def_string) do

    handle_result = fn
      :ok    -> IO.puts "Correct Prolog definition."; :correct
      :error -> IO.puts "Incorrect Prolog definition."; :error
    end

    defs = String.split(def_string, ".")
    handle_result.(handle_def(defs))

  end
end
