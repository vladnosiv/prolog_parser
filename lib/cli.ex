defmodule PrologParser.CLI do
  
  def main(args) do
    options = [switches: [file: :string], aliases: [f: :file]]
    {opts, _, _} = OptionParser.parse(args, options)
    handle_args(opts)
  end

  defp print_help_message() do
    IO.puts "Usage: prolog_parser -f [file]   check syntax in text file"
  end

  defp file_mode(filename) do
    {:ok, body} = File.read(filename)
    PrologParser.check_syntax(body)
  end

  defp handle_args(arg) do
    case arg do
      []        -> print_help_message()
      [file: x] -> file_mode(Kernel.inspect(x) |> String.trim("\"") |> String.trim_leading("\""))
      _         -> IO.puts "Unknown command.\nMore info with: \"./prolog_parser\""
    end
  end
end
