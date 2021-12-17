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
    -> main_definition    {% id %}
    |  proc_definition   {% id %}
    |  comment_statement {% id %}

main_definition
    -> begin __ code_block __ end
        {%
            d => ({
                type: "proc_definition",
                name: "main",
                body: d[2],
                start: tokenStart(d[0]),
                end: d[4].end
            })
        %}

proc_definition
    -> "proc" __ identifier __ code_block
        {%
            d => ({
                type: "proc_definition",
                name: d[2],
                parameters: d[6],
                body: d[10],
                start: tokenStart(d[0]),
                end: d[10].end
            })
        %}

code_block -> "[" executable_statements "]"
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

call_statement -> call_expression  {% id %}

call_expression
    -> execute identifier
        {%
            d => ({
                type: "call_expression",
                fun_name: d[0],
                arguments: d[3],
                start: d[0].start,
                end: tokenEnd(d[4])
            })
        %}

while_statement
    -> "while" __ expression __ code_block
        {%
            d => ({
                type: "while_statement",
                condition: d[2],
                body: d[4],
                start: tokenStart(d[0]),
                end: d[4].end
            })
        %}

if_statement
    -> "if" __ expression __ code_block
        {%
            d => ({
                type: "if_statement",
                condition: d[2],
                consequent: d[4],
                start: tokenStart(d[0]),
                end: d[4].end
            })
        %}
    |  "if" __ expression _ code_block _
       "else" __ code_block
        {%
            d => ({
                type: "if_statement",
                condition: d[2],
                consequent: d[4],
                alternate: d[8],
                start: tokenStart(d[0]),
                end: d[8].end
            })
        %}
    |  "if" __ expression _ code_block _
       "else" __ if_statement
       {%
            d => ({
                type: "if_statement",
                condition: d[2],
                consequent: d[4],
                alternate: d[8],
                start: tokenStart(d[0]),
                end: d[8].end
            })
       %}

repeat_statement
    -> repeat __ number __ times __ code_block
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
    -> is_margin         {% id %}
    |  is_not_margin     {% id %}

comment_statement -> %comment {% convertTokenId %}

number -> %number_literal {% convertTokenId %}

identifier -> %identifier {% convertTokenId %}

_ml -> multi_line_ws_char:*

multi_line_ws_char
    -> %ws
    |  "\n"

__ -> %ws:+

_ -> %ws:*

# This can be externalized into a lexer
# That would allow multiple languages

begin -> %begin {% id %}
end -> %end {% id %}

up -> %up {% id %}
down -> %down {% id %}
right -> %right {% id %}
left -> %left {% id %}

while -> %while {% id %}
execute -> %execute {% id %}

repeat -> %repeat {% id %}
times -> %times {% id %}

if -> %if {% id %}
then -> %then {% id %}
else -> %else {% id %}

is_margin -> %is_margin {% id %}
is_not_margin -> %is_not_margin {% id %}

procedure -> %procedure {% id %}