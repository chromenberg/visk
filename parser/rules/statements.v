module rules

import tokenizer {Token}

// A statement performs an action, like variable declaration or branching
pub struct Stmt {
pub:
	start Token
	end   Token
}

// Extends: Statement
pub struct DataDecl {
	Stmt
pub:
	// inner content of the data declaration
	inner Block
}

pub struct NamedDataDecl {
	DataDecl
pub:
	name Token
}

// Field of a builder like a slashcommand or embed
pub struct FieldStmt {}



pub type BlockInner = Stmt | NamedDataDecl | DataDecl | FlagBlock
pub struct Block {
pub:
	start Token         // The token where the block starts
	end   Token         // The token where the block ends
	inner []AnyStmt // The inside of a block could contain any statement
}

pub struct EventStmt {
pub:
	start Token
	name  Token
	inner Block
	end   Token
}


pub struct SimpleFunc {
	Block
pub:
	name Token
}

// A block containing only tokens, used for `intents`
pub struct FlagBlock {
pub:
	start Token
	end   Token
	inner []Token
}

// TODO: Need a field for parameters
pub struct Func {
	Block
	// pub:
	// params
}

// ? FunctionCall is in here as functions can be called without needing to be assigned
pub type AnyStmt = Stmt | NamedDataDecl | Func | SimpleFunc | FlagBlock | Block | DataDecl | EventStmt | FunctionCall