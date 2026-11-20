module main

import os
import tokenizer { Tokenizer }
import parser

fn main() {
	data := os.read_file('bot.visk')!
	mut tok := Tokenizer.new(data)
	defer { tok.destroy() }
	mut par := parser.Parser{source: tok}
	
	par.step()
	par.step()

	// os.write_file('./bot.visk.tokens', dat.str())!
}
