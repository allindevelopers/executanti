const moo = require("moo");

const keywords = {
	kw_begin: "BEGIN",
	kw_end: "END",

	kw_up: "UP",
	kw_down: "DOWN",
	kw_right: "RIGHT",
	kw_left: "LEFT",

	kw_while: "WHILE",
	kw_execute: "EXECUTE",

	kw_repeat: "REPEAT",
	kw_times: "TIMES",

	kw_if: "IF",
	kw_then: "THEN",
	kw_else: "ELSE",

	kw_is_margin: "IS_MARGIN",
	kw_is_not_margin: "IS_NOT_MARGIN",

	kw_procedure: "PROCEDURE",
};

const lexer = moo.compile({
	ws: /[ \t]+/,
	nl: { match: "\n", lineBreaks: true },
	comment: {
		match: /#[^\n]*/,
		value: (s) => s.substring(1),
	},
	number_literal: {
		match: /[0-9]+(?:\.[0-9]+)?/,
		value: (s) => Number(s),
	},
	identifier: {
		match: /[a-zA-Z_][a-zA-Z_0-9]*/,
		type: moo.keywords(keywords),
	},
	...keywords,
});

module.exports = lexer;
