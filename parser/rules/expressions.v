module rules

import tokenizer {Token}

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

// A function call is an unury expression, as we only care about what comes to the right of it
pub struct FunctionCall {
pub:
	name  Token  // Function Name
	inner Block // Parameters passed into function
}

// object.field
pub struct FieldAccess {
pub:
	name Token
	field &AnyExpr
}

pub type AnyExpr = FieldAccess | FunctionCall | BinaryExp