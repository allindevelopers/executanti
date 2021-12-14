@builtin "whitespace.ne"
@builtin "postprocessors.ne"

@{%
	const operation = value => () => ({ type: 'operation', value })
	const operations = d => d[0].map(([op]) => op)
	const block = d => ({ type: 'block', value: d[3] })
%}

MAIN -> BLOCK {% id %}

BLOCK -> _ BEGIN __ OPERATIONS __ END _ {% block %}

OPERATIONS -> (_ delimited[OPERATION, __] _ {% nth(1) %}) {% operations %}

OPERATION -> UP {% operation("UP") %}
OPERATION -> DOWN {% operation("DOWN") %}
OPERATION -> LEFT {% operation("LEFT") %}
OPERATION -> RIGHT {% operation("RIGHT") %}

# This can be externalized into a lexer
# That would allow multiple languages

BEGIN -> "BEGIN" {% id %}
END -> "END" {% id %}

UP -> "UP" {% id %}
DOWN -> "DOWN" {% id %}
RIGHT -> "RIGHT" {% id %}
LEFT -> "LEFT" {% id %}

WHILE -> "LEFT" {% id %}
EXECUTE -> "EXECUTE" {% id %}

REPEAT -> "REPEAT" {% id %}
TIMES -> "TIMES" {% id %}

IF -> "IF" {% id %}
THEN -> "THEN" {% id %}
ELSE -> "ELSE" {% id %}

IS_MARGIN -> "IS_MARGIN" {% id %}
IS_NOT_MARGIN -> "IS_NOT_MARGIN" {% id %}

PROCEDURE -> "PROCEDURE" {% id %}