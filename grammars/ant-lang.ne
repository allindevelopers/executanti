@{%
const lexer = require("./lexer");

function tokenStart(token) {
    return {
        line: token.line,
        col: token.col - 1
    };
}

function tokenEnd(token) {
    const lastNewLine = token.text.lastIndexOf("\n");
    if (lastNewLine !== -1) {
        throw new Error("Unsupported case: token with line breaks");
    }
    return {
        line: token.line,
        col: token.col + token.text.length - 1
    };
}

function convertToken(token) {
    return {
        type: token.type,
        value: token.value,
        start: tokenStart(token),
        end: tokenEnd(token)
    };
}

function convertTokenId(data) {
    return convertToken(data[0]);
}

%}

@lexer lexer

input -> top_level_statements {% id %}

top_level_statements
    ->  top_level_statement
        {%
            d => [d[0]]
        %}
    |  top_level_statement _ "\n" _ top_level_statements
        {%
            d => [
                d[0],
                ...d[4]
            ]
        %}
    # below 2 sub-rules handle blank lines
    |  _ "\n" top_level_statements
        {%
            d => d[2]
        %}
    |  _
        {%
            d => []
        %}

top_level_statement
    -> main_definition   {% id %}
    |  proc_definition   {% id %}
    |  comment_statement {% id %}

main_definition
    -> code_block
        {%
            d => ({
                type: "proc_definition",
                name: "main",
                body: d[0],
                start: tokenStart(d[0]),
                end: d[0].end
            })
        %}

proc_definition
    -> procedure __ identifier __ code_block
        {%
            d => ({
                type: "proc_definition",
                name: d[2],
                body: d[4],
                start: tokenStart(d[0]),
                end: d[4].end
            })
        %}

code_block -> begin executable_statements end
    {%
        (d) => ({
            type: "code_block",
            statements: d[1],
            start: tokenStart(d[0]),
            end: tokenEnd(d[2])
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
        {%
            d => [d[1], ...d[4]]
        %}

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
    -> execute identifier
        {%
            d => ({
                type: "call_statement",
                fun_name: d[1],
                start: d[0].start,
                end: tokenEnd(d[1])
            })
        %}

while_statement
    -> while __ expression __ code_block
        {%
            d => ({
                type: "while_statement",
                condition: d[2],
                body: d[6],
                start: tokenStart(d[0]),
                end: d[6].end
            })
        %}

if_statement
    -> if __ expression __ then __ code_block
        {%
            d => ({
                type: "if_statement",
                condition: d[2],
                consequent: d[6],
                start: tokenStart(d[0]),
                end: d[6].end
            })
        %}
    |  if __ expression __ then __ code_block __ else __ code_block
        {%
            d => ({
                type: "if_statement",
                condition: d[2],
                consequent: d[6],
                alternate: d[10],
                start: tokenStart(d[0]),
                end: d[10].end
            })
        %}

repeat_statement
    -> repeat __ number __ code_block
        {%
            d => ({
                type: "repeat_statement",
                iterable: d[2],
                body: d[6],
                start: tokenStart(d[0]),
                end: d[6].end
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

begin -> %kw_begin {% id %}
end -> %kw_end {% id %}

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