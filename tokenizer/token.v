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

pub struct Pos {
pub:
	file   string
	offset i32
	line   i32
	column i32
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
	login
	keyword_end
}
