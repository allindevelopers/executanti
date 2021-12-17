const moo = require("moo");

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
		match: /[a-zA-Z]*/,
		type: moo.keywords({
			begin: "BEGIN",
			end: "END",

			up: "UP",
			down: "DOWN",
			right: "RIGHT",
			left: "LEFT",

			while: "WHILE",
			execute: "EXECUTE",

			repeat: "REPEAT",
			times: "TIMES",

			if: "IF",
			then: "THEN",
			else: "ELSE",

			is_margin: "IS_MARGIN",
			is_not_margin: "IS_NOT_MARGIN",

			procedure: "PROCEDURE",
		}),
	},
});

module.exports = lexer;
