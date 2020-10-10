defmodule PrologParserTest do
  use ExUnit.Case
  doctest PrologParser

  test "simple correct defs" do
    assert PrologParser.parse("f.") != "Incorrect Prolog definition."
    assert PrologParser.parse("f :- g.") != "Incorrect Prolog definition."
    assert PrologParser.parse("f :- g, h; t.") != "Incorrect Prolog definition."
    assert PrologParser.parse("f :- g, (h; t).") != "Incorrect Prolog definition."
    assert PrologParser.parse("HSE :- workHard, dieYoung.") != "Incorrect Prolog definition."
  end

  test "simple incorrect defs" do
    assert PrologParser.parse("f") == "Incorrect Prolog definition."
    assert PrologParser.parse(":- f.") == "Incorrect Prolog definition."
    assert PrologParser.parse("f :- g; h, .") == "Incorrect Prolog definition."
    assert PrologParser.parse("f :- (g; (f).") == "Incorrect Prolog definition."
  end

  test "correct def with whitespaces" do
    assert PrologParser.parse("f    :-       d  ;     r ,        ttweAs     .") != "Incorrect Prolog definition."
  end

  test "incorrect def with whitespaces" do
    assert PrologParser.parse("   f :-     rAx , ( dsd ,   .") == "Incorrect Prolog definition."
  end

  test "incorrect def with error for lexer" do
    assert PrologParser.parse("1 :- f.") == "Incorrect Prolog definition."
  end

  test "correct defs" do
    assert PrologParser.parse("abc :- a, b, c.\nabc :- a; v, c.\n\na.\n\nb.\n\nc :- v, v.\nc :- b.\n\nv :- a; b.") == ['Definition (abc) (Conjunction (a) (Conjunction (b) (c)))', 'Definition (abc) (Disjunction (a) (Conjunction (v) (c)))', 'Definition (a)', 'Definition (b)', 'Definition (c) (Conjunction (v) (v))', 'Definition (c) (b)', 'Definition (v) (Disjunction (a) (b))']
    assert PrologParser.parse("\nf\n\n\n.\n\nf :-\n\na, h, k.\nf    :- ((h, k), l) ; m.") != "Incorrect Prolog definition."
  end

  test "correct def with nested parens" do
    assert PrologParser.parse("x :- (x, y) ; z ; y; x, (x, (y, z) ; (p, q)).") != "Incorrect Prolog definition."
    assert PrologParser.parse("a :- ((b ; c) , (d) ; e) , (a, b , (c ; (d))).") != "Incorrect Prolog definition."
  end


  test "check correct tree" do
    assert PrologParser.parse("a b c.") == ['Definition (Atom (a) (b) (c))']
    assert PrologParser.parse("odd (cons H (cons H1 T)) (cons H T1) :- odd T T1.") == ['Definition (Atom (odd) (Brackets (Atom (cons) (H) (Brackets (Atom (cons) (H1) (T))))) (Brackets (Atom (cons) (H) (T1)))) (Atom (odd) (T) (T1))']
  end

end
