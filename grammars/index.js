const { Parser, Grammar } = require("nearley");
const compile = require("nearley/lib/compile.js");
const generate = require("nearley/lib/generate.js");
const nearleyGrammar = require("nearley/lib/nearley-language-bootstrapped.js");
const fs = require("fs");

function compileGrammar(sourceCode) {
	// Parse the grammar source into an AST
	const grammarParser = new Parser(nearleyGrammar);
	grammarParser.feed(sourceCode);
	const grammarAst = grammarParser.results[0]; // TODO check for errors

	// Compile the AST into a set of rules
	const grammarInfoObject = compile(grammarAst, {});
	// Generate JavaScript code from the rules
	const grammarJs = generate(grammarInfoObject, "grammar");

	// fs.writeFileSync('./ant.js', grammarJs)

	// Pretend this is a CommonJS environment to catch exports from the grammar.
	const module = { exports: {} };

	eval(grammarJs);

	return module.exports;
}

const ant = fs.readFileSync("./grammars/ant-lang.ne", { encoding: "utf8" });

const rules = compileGrammar(ant);

const grammar = Grammar.fromCompiled(rules);

const parser = new Parser(grammar);

const inFile = fs.readFileSync("./grammars/input.ant", "utf8");
parser.feed(inFile);

const [result] = parser.finish();

fs.writeFileSync("./grammars/output.json", JSON.stringify(result, null, "\t"));

function evaluate(json) {
	// ...
}

evaluate({});
