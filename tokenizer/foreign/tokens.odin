package main
import "core:c"
TOKEN_KIND :: enum c.int {
	Invalid,
	EOF,
	Comment,

	Literal_Start,
		Identifier,
		String,
		Number,
		// New_Line,
		// TODO: Hex? Pixel?
		// maybe other value types css has
	Literal_End,

	Operator_Start,
		Maths_Start,
			Add,
			Sub,
			Mul,
			Div,
			Mod,
			Gt,
			Lt,
			Eq,
		Maths_End,

		Pipe,
		Ampersand,
		Question,
		Exclam,

		At,
		Hash,
		Open_Paren,			// (
		Close_Paren,		// )
		Open_Bracket,		// [
		Close_Bracket,	// ]
		Open_Brace,			// {
		Close_Brace,		// }
		Colon,					// :
		Semicolon,			// ;
		Period,					// .
		Comma,
		Quote,
		Apostrophe,
		Backtick,		// ,
		Whitespace, // Needed because spaces in CSS actually mean something for some stupid reason

		Left_Arrow,
		Right_Arrow,

	Operator_End,

	Keyword_Start,
		Client,
		Intent,
		Data,
		On,
		Once,
		Command,
		Option,
		End,
		Required,
		Function,
		Return,
		Enum,
		Class,
		Public,
		Login,
	Keyword_End,

	COUNT
}

TOKENS := [TOKEN_KIND.COUNT]string{
	"Invalid",
	"EOF",
	"Comment",

	"",
		"identifier",
		"string",
		"number",
		// "\n",
	"",

	"",
		"",
			"+",
			"-",
			"*",
			"/",
			"%",
			">",
			"<",
			"=",
		"",

		"|",
		"&",
		"?",
		"!",

		"@",
		"#",

		"(",
		")",
		"[",
		"]",
		"{",
		"}",
		":",
		";",
		".",
		",",
		"\"",
		"'",
		"`",
		" ",

		"->",
		"<-",
	"",

	"",
		"client",
		"intents",
		"data",
		"on",
		"once",
		"command",
		"option",
		"end",
		"required",
		"function",
		"return",
		"enum",
		// Maybe we could have classes?
		"class",
		"public",
		"login",
	""
}

Token :: struct {
	kind:     TOKEN_KIND,
	text:     ^u8, // borrowed view into Tokenizer.source
	text_len: c.int,
	pos:      Pos,
}

Pos :: struct {
	offset: c.int, // 0
	line:   c.int, // 1
	column: c.int, // 1
}

is_literal :: proc(kind: TOKEN_KIND) -> bool {
	return .Literal_Start < kind && kind < .Literal_End
}

is_operator :: proc(kind: TOKEN_KIND) -> bool {
	return .Operator_Start < kind && kind < .Operator_End
}

is_keyword :: proc(kind: TOKEN_KIND) -> bool {

	return .Keyword_Start < kind && kind < .Keyword_End
}

get_kind :: proc(text: string) -> TOKEN_KIND {
	// probably very inefficient
	for kind in TOKEN_KIND {
		if TOKENS[kind] == text do return kind
	}

	return .Invalid
}

get_keyword :: proc(text: string) -> Maybe(TOKEN_KIND) {
	for kind in TOKEN_KIND {
		if is_keyword(kind) && TOKENS[kind] == text do return kind
	}
	return nil
}

offset_to_pos :: proc(t: ^Tokenizer, offset: c.int) -> Pos {
	line := t.line_count
	column := t.offset - t.line_offset + 1

	return Pos {
		column = c.int(column),
		line =   c.int(line),
		offset = c.int(offset)
	}
}
