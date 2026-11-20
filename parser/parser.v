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

fn (this &Parser) expect(kind tok.TokenKind) bool {
	peeked := this.source.peek()
	if peeked.kind != kind { return false }
	return true
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
	if !this.expect(.intent) {
		panic("Malformed client declaration, intents were not defined first")
	} // TODO: Should be able to expect this at any point
	this.advance()
	intent_start := this.current
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

fn (this &Parser) parse_binary_expr() {}
fn (this &Parser) parse_unury_expr() {}

fn (this &Parser) parse_body() rules.Block {
	start := this.current
	mut inner := []rules.AnyStmt{}

	for {
		stmt, end := this.parse_statements()
		if end {break}
		if stmt != none {
			inner << stmt
		}

	}

	if !this.expect(.end) {
		panic("Malformed block statement")
	} // if the next token is end then we are about to leave this scope
	// this.advance()

	return rules.Block{
		start: start
		end: this.current
		inner: inner
	}
}

fn (this &Parser) parse_block() {}
fn (this &Parser) parse_function() {}
fn (this &Parser) parse_statements() (?rules.AnyStmt, bool) {
	match this.current.kind {
		// .function {}
		// .option {}
		// .data {}
		.client {
			return this.parse_client_decl(), this.expect(.end)
		}
		// .command {}
		.on, .once {
			return this.parse_event(), this.expect(.end)
		}
		else {
			// If nothing matches return nothing and say that we reached the end
			// this.advance()
			println("No matched ${this.current}")
			this.advance()
			return none, this.expect(.end)
		}
	}
}
// An event is anything that doesnt need arguments or to be called
// And has a name
fn (this &Parser) parse_event() rules.EventStmt {
	// On, Once, Command
	keyword := this.current

	if !this.expect(.identifier) {panic("Cant create event block with no name")}
	this.advance()

	name := this.current
	this.advance()
	// We have entered the events body, parse the statements into a block
	
	event_body := this.parse_body()
	this.advance()

	return rules.EventStmt{
		start: keyword
		name: name
		inner: event_body
		end: this.current
	}
}

pub fn (this &Parser) step() {
	
	stmt, end := this.parse_statements()
	println("Statement: ${stmt} | End?: ${end}")
}
