package main

import "core:unicode"
import "core:log"
import "core:unicode/utf8"
import "core:fmt"
import "core:strings"
import "core:os"
import "core:mem"
import "base:runtime"
import "core:c"

Tokenizer :: struct {
	file: string,
	source: string,
	
	// we could get away with using a pointer to ensure no weird leaks
	// however trying to print this would result in some issues
	// tokens: [dynamic]Token,
	// the offset the cursor has relative to the current "line"
	line_offset: c.int,
	line_count: c.int,
	read_offset: c.int,
	// the total offset of the cursor
	offset: c.int,
	current: rune,
}

is_token :: proc(text: string) -> bool{
	for token in TOKENS {
		if text == token do return true
	}
	return false
}

create_token :: proc(t: ^Tokenizer, text: string, line: c.int, column: c.int) {
	token : Token
	token.kind = get_kind(text)
	token.pos.line = line
	token.pos.column = column
	// append(&t.tokens, token)
}

advance_rune :: proc(t: ^Tokenizer) {
	// fmt.println(t.read_offset, len(t.source))
	if t.read_offset < c.int(len(t.source)) {
		t.offset = t.read_offset

		if t.current == '\n' {
			// the current line is this far into the string
			t.line_offset = t.offset
			t.line_count += 1
		}

		r, width := rune(t.source[t.read_offset]), 1
		
		t.read_offset += c.int(width)
		t.current = r
	} else {
		t.offset = c.int(len(t.source))
		
		if t.current == '\n' {
			// the current line is this far into the string
			t.line_offset = t.offset
			t.line_count += 1
		}

		// no more chars left
		t.current = -1
	}
}

skip_whitespace :: proc(t: ^Tokenizer) {
	for {
		switch t.current {
			case ' ', '\t', '\r', '\n':
				// fmt.println("skip")
				advance_rune(t)
			case:
				return
		}
	}
}

@(export)
is_letter :: proc "c" (r: rune) -> bool {
	context = runtime.default_context()
	if r < utf8.RUNE_SELF {
		switch r {
		case '_':
			return true
		case 'A'..='Z', 'a'..='z':
			return true
		}
	}
	return unicode.is_letter(r)
}

@(export)
is_digit :: proc "c" (r: rune) -> bool {
	context = runtime.default_context()

	if '0' <= r && r <= '9' {
		return true
	}
	return unicode.is_digit(r)
}

read_string :: proc(t: ^Tokenizer) -> string {
	offset := t.offset-1

	// keep reading until we find another string literal token
	for {
		current := t.current
		// if newline or ran out of chars then string not terminated
		if current == '\n' || current < 0 {
			log.errorf("string literal @[line:column] was not terminated")
			break
		}
		advance_rune(t)
		if current == '"' {
			break
		}
	}

	return string(t.source[offset : t.offset])
}

read_identifier :: proc(t: ^Tokenizer) -> string {
	offset := t.offset

	for is_letter(t.current) || is_digit(t.current) {
		advance_rune(t)
	}

	return string(t.source[offset:t.offset])
}

is_class :: proc (t: ^Tokenizer) -> bool {
	if !is_letter(t.current) || !is_digit(t.current) || t.current != '_' {
		return false
	}
	return !is_letter(t.current) || !is_digit(t.current) || t.current != '_'
}



@(export)
peek :: proc "c" (t: ^Tokenizer) -> Token {
	context = runtime.default_context()
	new := t^ // this might still edit the other tokenizer
	peeked := next_token(&new)
	return peeked
}

@(export)
lookahead :: proc "c" (t: ^Tokenizer, amount: c.int) -> (peeked: Token) {
	context = runtime.default_context()
	new := t^ // this might still edit the other tokenizer
	// 0,1,2,3
	// lookahead 3 tokens, 0,1,2
	for i : c.int = 1; i <= amount; i += 1 {
		peeked = next_token(&new)
	}
	return peeked
}


@(export)
next_token :: proc "c" (t: ^Tokenizer) -> Token{
	context = runtime.default_context()
	skip_whitespace(t)
	
	offset := t.offset
	kind: TOKEN_KIND
	text: string
	pos := offset_to_pos(t, offset)

	switch current := t.current; true {
		case is_letter(current):
			text = read_identifier(t)
			kind = .Identifier

			keywd_kind := get_keyword(text)
			if keywd_kind != nil {
				kind = keywd_kind.(TOKEN_KIND)
			} 

		case:
			advance_rune(t)
			switch current {
				case -1:
					kind = .EOF
				// case '\n': kind = .New_Line
				case '{': kind = .Open_Brace
				case '}': kind = .Close_Brace
				case '(': kind = .Open_Paren
				case ')': kind = .Close_Paren
				case '[': kind = .Open_Bracket
				case ']': kind = .Close_Bracket
					// these need a check
				case '.': kind = .Period
				case '#': kind = .Hash
				case ',': kind = .Comma
				case '+': kind = .Add
				case '-': kind = .Sub
				case '*': kind = .Mul
				case '/': kind = .Div
				case '%': kind = .Mod
				case '>': kind = .Gt
				case '<': kind = .Lt
				case '=': kind = .Eq
				case '|': kind = .Pipe
				case '&': kind = .Ampersand
				case '?': kind = .Question
				case '!': kind = .Exclam
				case '"': kind = .Quote
				case '\'': kind = .Apostrophe
				case '`': kind = .Backtick
					
			}
	}

	if text == "" {
		text = string(t.source[offset : t.offset])
	}
	token := Token{kind, text, pos}
	// append(&t.tokens, token)

	return token
}

@(export)
new_tokenizer :: proc "c" (source: cstring) -> ^Tokenizer {
	context = runtime.default_context()
	tok := new(Tokenizer)
	str, err := strings.clone_from_cstring(source)
	
	if err != nil {
		fmt.eprintln(err)
		return nil
	}
	tok.source = str
	return tok
}

@(export)
free_tokenizer :: proc "c" (t: ^Tokenizer) {
	context = runtime.default_context()
	free(t)
}