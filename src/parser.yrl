Nonterminals definition body expr atom atomInterior atomNext.
Terminals id corkscrew dot conj disj lparen rparen.
Rootsymbol definition.

Right 100 disj.
Right 200 conj.

definition -> atom corkscrew body : "Definition (" ++ '$1' ++ ") (" ++ '$3' ++ ")".
definition -> atom dot : "Definition (" ++ '$1' ++ ")".

body -> expr dot : '$1'.

expr -> lparen expr rparen : "Brackets (" ++ '$2' ++ ")".
expr -> expr disj expr : "Disjunction (" ++ '$1' ++ ") (" ++ '$3' ++ ")".
expr -> expr conj expr : "Conjunction (" ++ '$1' ++ ") (" ++ '$3' ++ ")".
expr -> atom : '$1'.

atom -> id : value_of('$1').
atom -> id atomNext : "Atom (" ++ value_of('$1') ++ ") " ++ '$2'.

atomNext -> atomInterior atomNext : "(" ++ '$1' ++ ") " ++ '$2'.
atomNext -> id atomNext : "(" ++ value_of('$1') ++ ") " ++ '$2'.
atomNext -> atomInterior : "(" ++ '$1' ++ ")".
atomNext -> id : "(" ++ value_of('$1') ++ ")".

atomInterior -> lparen atomInterior rparen : "Brackets (" ++ '$2' ++ ")".
atomInterior -> lparen atom rparen : "Brackets (" ++ '$2' ++ ")".

Erlang code.

value_of(Token) ->
    element(3, Token).
