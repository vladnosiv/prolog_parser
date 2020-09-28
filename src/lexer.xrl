Definitions.

IDENTIFIER = [a-z_A-Z]+
WHITESPACE = [\s\t\n\r]

Rules.
\.             : {token, {dot, TokenLine}}.
\;             : {token, {disj, TokenLine}}.
\(             : {token, {lparen , TokenLine}}.
\)             : {token, {rparen, TokenLine}}.
\:\-           : {token, {sep, TokenLine}}.
,              : {token, {comma , TokenLine}}.
{IDENTIFIER}   : {token, {identifier, TokenLine}}.
{WHITESPACE}+  : skip_token.

Erlang code.
