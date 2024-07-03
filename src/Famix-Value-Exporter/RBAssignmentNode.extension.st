Extension { #name : #RBAssignmentNode }

{ #category : #'*Famix-Value-Exporter' }
RBAssignmentNode >> addParenthesisToVariable [
	"add parenthesis because the node as multiple references"

	| receiver newNode |
	receiver := RBAssignmentNode new
		            variable: self variable;
		            value: (self value messages at: 1) receiver.
	newNode := self value.
	(newNode messages at: 1) receiver: receiver.
	^ newNode
]
