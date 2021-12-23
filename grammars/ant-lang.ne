@{%
const lexer = require("./lexer");
const { tokenStart, tokenEnd, convertTokenId } = require('./utils')
%}

@lexer lexer

input -> top_level_statements {% id %}

top_level_statements
    -> top_level_statement
        {% d => [d[0]] %}
    |  top_level_statement _ "\n" _ top_level_statements
        {% d => [d[0], ...d[4]] %}
    # below 2 sub-rules handle blank lines
    |  _ "\n" top_level_statements
        {% d => d[2] %}
    |  _
        {% d => [] %}

top_level_statement
    -> main_definition   {% id %}
    |  proc_definition   {% id %}
    |  comment_statement {% id %}

main_definition
    -> main_begin _ code_block _ main_end
        {%
            d => ({
                type: "proc_definition",
                name: "main",
                body: d[2],
                start: tokenStart(d[0]),
                end: tokenEnd(d[4])
            })
        %}

proc_definition
    -> procedure __ identifier __ main_begin _ code_block _ main_end
        {%
            d => ({
                type: "proc_definition",
                name: d[2],
                body: d[6],
                start: tokenStart(d[0]),
                end: tokenEnd(d[8])
            })
        %}

code_block -> executable_statements
    {%
        (d) => ({
            type: "code_block",
            statements: d[0],
        })
    %}

executable_statements
    -> _
        {% () => [] %}
    |  _ "\n" executable_statements
        {% (d) => d[2] %}
    |  _ executable_statement _
        {% d => [d[1]] %}
    |  _ executable_statement _ "\n" executable_statements
        {% d => [d[1], ...d[4]] %}

executable_statement
   -> call_statement       {% id %}
   |  comment_statement    {% id %}
   |  while_statement      {% id %}
   |  if_statement         {% id %}
   |  repeat_statement     {% id %}
   |  up                   {% id %}
   |  down                 {% id %}
   |  right                {% id %}
   |  left                 {% id %}

call_statement
    -> execute __ identifier
        {%
            d => ({
                type: "call_statement",
                fun_name: d[2],
                start: d[0].start,
                end: d[2].end
            })
        %}

while_statement
    -> while __ expression __ main_begin _ code_block _ main_end
        {%
            d => ({
                type: "while_statement",
                condition: d[2],
                body: d[6],
                start: tokenStart(d[0]),
                end: tokenEnd(d[8])
            })
        %}

if_statement
    -> if __ expression __ then __ main_begin _ code_block _ main_end
        {%
            d => ({
                type: "if_statement",
                condition: d[2],
                consequent: d[8],
                start: tokenStart(d[0]),
                end: tokenEnd(d[10])
            })
        %}
    |  if __ expression __ then __ main_begin _ code_block _ main_end __ else __ main_begin _ code_block _ main_end
        {%
            d => ({
                type: "if_statement",
                condition: d[2],
                consequent: d[8],
                alternate: d[16],
                start: tokenStart(d[0]),
                end: tokenEnd(d[18])
            })
        %}

repeat_statement
    -> repeat __ number __ main_begin _ code_block _ main_end
        {%
            d => ({
                type: "repeat_statement",
                iterable: d[2],
                body: d[6],
                start: tokenStart(d[0]),
                end: tokenEnd(d[8])
            })
        %}

expression
    -> is_margin {% id %}
    |  is_not_margin {% id %}

comment_statement -> %comment {% convertTokenId %}
number -> %number_literal {% convertTokenId %}
identifier -> %identifier {% convertTokenId %}

__ -> %ws:+
_ -> %ws:*

# Externalized tokens allow multiple languages

main_begin -> %kw_main_begin {% id %}
main_end -> %kw_main_end {% id %}

up -> %kw_up {% id %}
down -> %kw_down {% id %}
right -> %kw_right {% id %}
left -> %kw_left {% id %}

while -> %kw_while {% id %}
execute -> %kw_execute {% id %}

repeat -> %kw_repeat {% id %}
times -> %kw_times {% id %}

if -> %kw_if {% id %}
then -> %kw_then {% id %}
else -> %kw_else {% id %}

is_margin -> %kw_is_margin {% id %}
is_not_margin -> %kw_is_not_margin {% id %}

procedure -> %kw_procedure {% id %}