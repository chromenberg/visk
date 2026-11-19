module main

import os
import tokenizer { Tokenizer }

fn main() {
	data := os.read_file('bot.visk')!
	mut tok := Tokenizer.new(data)
	defer { tok.destroy() }
	for {
		token := tok.next()
		println('${token.kind}')

		if token.kind == .eof {
			break
		}
	}
}
