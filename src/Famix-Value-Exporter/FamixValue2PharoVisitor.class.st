"
A visitor for exporting a FamixValue model to the Pharo AST, see `RBEntity` and `RBNode`.

Object attributes are initialized by finding the corresponding setters.
Collections and Dictionaries are constructed with the `withAll:` class method.
"
Class {
	#name : #FamixValue2PharoVisitor,
	#superclass : #FamixValue2ASTVisitor,
	#category : #'Famix-Value-Exporter'
}
