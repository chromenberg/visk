module rules

import tokenizer { Token }

// TODO: These could use the modified V compiler but would restrict who can use it

pub struct BaseOp {
pub:
	start int
	end   int
	tok   Token
}

// Defines an unury operator, like incrementing or decrementing
// +x x+, doesnt care if there is something in one direction
pub struct UnuryOp {
	BaseOp
}

pub struct BinaryOp {
	BaseOp
pub:
	left  Token
	right Token
}

pub struct Expr {
}

pub struct Type {
	BaseOp
}

pub struct TypeDecl {
pub:
	start Token // should be <
	inner Type
	end   Token // should be >
}

// A statement performs an action, like variable declaration or branching
pub struct Stmt {
pub:
	start Token
	end   Token
}

pub struct Block {
pub:
	start Token         // The token where the block starts
	end   Token         // The token where the block ends
	inner []union{Stmt} // The inside of a block could contain any statement
}

pub struct BlockArray {
pub:
	values []Token // TODO: This should be multiple variables or something
}

pub struct ClientDecl {
	Block
}

// TODO: Need a field for parameters
pub struct SimpleFunc {
	Block
	// pub:
	// params
}
