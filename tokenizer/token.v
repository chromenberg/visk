module tokenizer

// pub struct Token {
// 	line   int
// 	column int
// 	text   string
// 	start  int
// 	end    int
// 	type   TokenKind
// }

// pub enum TokenKind {
// 	identifier
// 	declaration
// 	open_paren
// 	close_paren
// 	quote
// }

pub struct Token {
pub:
	kind TokenKind
	text string
	pos  Pos
}

// `RawToken` mirrors the Odin `Token` struct (tokenizer/foreign/tokens.odin)
// byte for byte. It is only used to move data across the FFI boundary.
//
// Keep the field order and types identical to the Odin side: V's `string` is
// 24 bytes (`str`, `len`, `is_lit`) while Odin's `string` is 16 bytes (`data`,
// `len`), so a `string` field here would shift every field after it, and the
// garbage lengths that produces crash the allocator when the token is printed.
// Use a raw pointer + length instead, and build the V string in `to_token()`.
struct RawToken {
	kind     TokenKind
	text     &u8 // borrowed view into the tokenizer's source buffer
	text_len i32
	pos      Pos
}

pub struct Pos {
pub:
	offset i32
	line   i32
	column i32
}


fn (raw RawToken) to_token() Token {
	text := if raw.text_len > 0 { 
		unsafe { tos(raw.text, int(raw.text_len)).clone() } 
	} else { '' }
	return Token{
		kind: raw.kind
		text: text
		pos:  raw.pos
	}
}

pub enum TokenKind {
	invalid
	eof
	comment

	literal_start
	identifier
	str
	number
	// newline
	// TODO: Hex? Pixel?
	// maybe other value types css has
	literal_end

	operator_start
	maths_start
	add
	sub
	mul
	div
	mod
	gt
	lt
	eq
	maths_end

	pipe
	ampersand
	question
	exclam

	at
	hash

	open_paren    // (
	close_paren   // )
	open_bracket  // [
	close_bracket // ]
	open_brace    // {
	close_brace   // }
	colon         // :
	semicolon     // ;
	period        // .
	comma
	quote
	apostrophe
	backtick   // ,
	whitespace // Needed because spaces in CSS actually mean something for some stupid reason
	right_arrow
	left_arrow
	operator_end

	keyword_start
	client
	intent
	data
	on
	once
	command
	option
	end
	required
	function
	return
	enum
	class
	public
	login
	keyword_end
}
