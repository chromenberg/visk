module tokenizer

#flag @DIR/foreign.a

fn C.new_tokenizer(data &char) &Tokenizer
fn C.free_tokenizer(t &Tokenizer)
fn C.next_token(t &Tokenizer) Token

pub struct Tokenizer {
	file   string
	source string

mut:
	line_offset i32
	line_count  i32
	read_offset i32
	offset      i32
	current     char
}

pub fn Tokenizer.new(data string) &Tokenizer {
	return C.new_tokenizer(data.str)
}

pub fn (tok &Tokenizer) next() Token {
	return C.next_token(tok)
}

pub fn (tok &Tokenizer) destroy() {
	C.free_tokenizer(tok)
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
