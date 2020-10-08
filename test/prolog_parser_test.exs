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
    assert PrologParser.check_syntax("f    :-       d  ;     r ,        ttweAs     .") == :correct
  end

  test "incorrect def with whitespaces" do
    assert PrologParser.check_syntax("   f :-     rAx , ( dsd ,   .") == :error
  end

  test "incorrect def with error for lexer" do
    assert PrologParser.check_syntax("1 :- f.") == :error
  end

  test "correct defs" do
    assert PrologParser.check_syntax("abc :- a, b, c.\nabc :- a; v, c.\n\na.\n\nb.\n\nc :- v, v.\nc :- b.\n\nv :- a; b.") == :correct
    assert PrologParser.check_syntax("\nf\n\n\n.\n\nf :-\n\na, h, k.\nf    :- ((h, k), l) ; m.") == :correct
  end

  test "correct def with nested parens" do
    assert PrologParser.check_syntax("x :- (x, y) ; z ; y; x, (x, (y, z) ; (p, q)).") == :correct
    assert PrologParser.check_syntax("a :- ((b ; c) , (d) ; e) , (a, b , (c ; (d))).") == :correct
  end

end
