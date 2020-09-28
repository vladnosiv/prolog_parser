defmodule PrologParserTest do
  use ExUnit.Case
  doctest PrologParser

  test "simple correct defs" do
    assert PrologParser.checkSyntax("f.") == :correct
    assert PrologParser.checkSyntax("f :- g.") == :correct
    assert PrologParser.checkSyntax("f :- g, h; t.") == :correct
    assert PrologParser.checkSyntax("f :- g, (h; t).") == :correct
    assert PrologParser.checkSyntax("HSE :- workHard, dieYoung.") == :correct
  end

  test "simple incorrect defs" do
    assert PrologParser.checkSyntax("f") == :error
    assert PrologParser.checkSyntax(":- f.") == :error
    assert PrologParser.checkSyntax("f :- g; h, .") == :error
    assert PrologParser.checkSyntax("f :- (g; (f).") == :error
   end

end
