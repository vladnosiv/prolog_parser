defmodule PrologParserTest do
  use ExUnit.Case
  doctest PrologParser

  test "simple correct defs" do
    assert PrologParser.check_syntax("f.") == :correct
    assert PrologParser.check_syntax("f :- g.") == :correct
    assert PrologParser.check_syntax("f :- g, h; t.") == :correct
    assert PrologParser.check_syntax("f :- g, (h; t).") == :correct
    assert PrologParser.check_syntax("HSE :- workHard, dieYoung.") == :correct
  end

  test "simple incorrect defs" do
    assert PrologParser.check_syntax("f") == :error
    assert PrologParser.check_syntax(":- f.") == :error
    assert PrologParser.check_syntax("f :- g; h, .") == :error
    assert PrologParser.check_syntax("f :- (g; (f).") == :error
  end

  test "correct def with whitespaces" do
    assert PrologParser.check_syntax("f    :-       d  ;     r ,        ttweAs     .")
  end

  test "incorrect def with whitespaces" do
    assert PrologParser.check_syntax("   f :-     rAx , ( dsd ,   .")
  end

end
