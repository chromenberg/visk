module tokenizer

#flag @DIR/foreign.a

fn C.new_tokenizer(data &char) &Tokenizer
fn C.free_tokenizer(t &Tokenizer)
fn C.next_token(t &Tokenizer) RawToken
fn C.peek(t &Tokenizer) RawToken
fn C.lookahead(t &Tokenizer, amount i32) RawToken

@[heap]
pub struct Tokenizer {
	handle voidptr
}

pub fn Tokenizer.new(data string) &Tokenizer {
	return C.new_tokenizer(data.str)
}

pub fn (tok &Tokenizer) next() Token {
	return C.next_token(tok).to_token()
}

pub fn (tok &Tokenizer) destroy() {
	C.free_tokenizer(tok)
}

pub fn (tok &Tokenizer) peek() Token {
	return C.peek(tok).to_token()
}

pub fn (tok &Tokenizer) lookahead(amount int) Token {
	return C.lookahead(tok, i32(amount)).to_token()
}

// fn (mut tok Tokenizer) next_token() {
// 	if tok.file_pos >= tok.data.len {
// 		tok.file_pos = -1
// 		return
// 	}
// 	tok.file_pos += 1
// }

// fn (mut tok Tokenizer) scan_ident() {
// 	index := tok.file_pos
// 	for {
// 		println('sdfs')
// 		current := tok.data[tok.file_pos]
// 		match current {
// 			`A`...`Z`,
// 			`a`...`z` {
// 				println('is alphabetical')
// 			}
// 			else {
// 				unsafe {
// 					goto after
// 				}
// 				return
// 			}
// 		}
// 		tok.next_token()
// 	}
// 	#after
// 	tok.cur = Token{
// 		line:   tok.line
// 		column: tok.pos
// 		text:   tok.data.substr(index, tok.file_pos)
// 		start:  index
// 		end:    tok.file_pos
// 	}
// }

// pub fn (mut tok Tokenizer) scan() ?Token {
// 	// for {
// 	if tok.file_pos >= tok.data.len {
// 		tok.index = -1
// 		return none
// 	}
// 	tok.scan_ident()
// 	// tok.file_pos += 1
// 	return tok.cur
// 	// }
// }
