module parser

import tokenizer as tok
import rules
import net.s3

pub struct Parser {
pub:
	source &tok.Tokenizer
mut:
	// The token the parser is currently on
	current tok.Token
	// The token the parser was on previously
	prev tok.Token

	// Current index of the parser
	index int
}

fn (this &Parser) expect(kind tok.TokenKind) ?tok.Token {
	peeked := this.source.peek()
	if peeked.kind != kind { return none }
	return peeked
}

fn (this &Parser) expect_or_end(kind tok.TokenKind) (?tok.Token, bool) {
	peeked := this.source.peek()
	if peeked.kind == .end {
		return peeked, true
	} else if peeked.kind != kind {
		return none, false
	}
	return peeked, false
}

fn (mut this Parser) advance() {
	this.current = this.source.next()
	this.index++
}

fn (this &Parser) parse_client_decl() rules.DataDecl {
	start := this.current
	intent_start := this.expect(.intent) or {
		panic("Malformed client declaration, intents were not defined first")
	} // TODO: Should be able to expect this at any point

	this.advance()
	mut intents := []tok.Token{}

	for {
		intent, ended := this.expect_or_end(.identifier)
		this.advance()

		if ended {
			break
		}
		if intent != none {
			intents << intent
		}
	}

	intent_end := this.current

	intents_block := rules.FlagBlock{
		start: intent_start
		end: intent_end
		inner: intents
	}

	this.expect(.end)
	this.advance()

	return rules.DataDecl{
		start: start
		end: this.current
		inner: rules.Block{
			start: start // the block just starts and ends with the declaration for now
			end: this.current
			inner: [intents_block]
		}
	}

}

pub fn (this &Parser) step() {
	this.advance()
	match this.current.kind {
		.client {
			println(this.parse_client_decl())
		}
	}
	// }
}
