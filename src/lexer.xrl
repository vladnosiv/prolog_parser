Definitions.

IDENTIFIER = [a-z_A-Z][a-z_A-Z0-9]*
WHITESPACE = [\s\t\n\r]

Rules.
\.             : {token, {dot, TokenLine}}.
\;             : {token, {disj, TokenLine}}.
\(             : {token, {lparen, TokenLine}}.
\)             : {token, {rparen, TokenLine}}.
\:\-           : {token, {corkscrew, TokenLine}}.
,              : {token, {conj, TokenLine}}.
{IDENTIFIER}   : {token, {id, TokenLine, TokenChars}}.
{WHITESPACE}+  : skip_token.

Erlang code.
