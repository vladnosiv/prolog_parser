Definitions.

IDENTIFIER = [a-z_A-Z]+
WHITESPACE = [\s\t\n\r]

Rules.
\.             : {token, dot}.
\;             : {token, disj}.
\(             : {token, lparen}.
\)             : {token, rparen}.
\:\-           : {token, sep}.
,              : {token, comma}.
{IDENTIFIER}   : {token, identifier}.
{WHITESPACE}+  : skip_token.

Erlang code.
