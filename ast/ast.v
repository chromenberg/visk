module ast
import rules


pub struct Ast {
pub:
	file string
pub mut:
	stmts []rules.AnyStmt
}


pub fn (mut this Ast) add(stmt rules.AnyStmt) {
	this.stmts << stmt
}
