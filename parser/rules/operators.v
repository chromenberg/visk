module rules
import tokenizer {Token}
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

