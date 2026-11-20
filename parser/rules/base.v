module rules

import tokenizer { Token }

// TODO: These could use the modified V compiler but would restrict who can use it

pub struct BaseOp {
pub:
	start int
	end   int

}

// Defines an unury operator, like incrementing or decrementing
// +x x+, doesnt care if there is something in one direction
pub struct UnuryOp {
	BaseOp
pub:
	op Token
}


pub struct Expr {
}

pub struct BinaryExp {
	BaseOp
pub:
	left 	Token
	op   	Token
	right Token
}


pub struct Type {
	BaseOp
pub:
	name Token
}

pub struct TypeDecl {
pub:
	start Token // should be <
	inner Type
	end   Token // should be >
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

// A statement performs an action, like variable declaration or branching
pub struct Stmt {
pub:
	start Token
	end   Token
}


pub type BlockInner = Stmt | NamedDataDecl | DataDecl | FlagBlock
pub struct Block {
pub:
	start Token         // The token where the block starts
	end   Token         // The token where the block ends
	inner []BlockInner // The inside of a block could contain any statement
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
