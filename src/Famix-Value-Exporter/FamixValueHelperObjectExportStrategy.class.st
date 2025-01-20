"
I generate the code to recreate objects in helper functions.
For each object, a dedicated function is generated that takes no arguments and returns the recreated object.
"
Class {
	#name : 'FamixValueHelperObjectExportStrategy',
	#superclass : 'FamixValueAbstractObjectExportStrategy',
	#instVars : [
		'declarations',
		'currentDeclarations'
	],
	#category : 'Famix-Value-Exporter-Strategies',
	#package : 'Famix-Value-Exporter',
	#tag : 'Strategies'
}

{ #category : 'ast' }
FamixValueHelperObjectExportStrategy >> buildMethodFor: object withParametersFor: attributes on: visitor [
	"Build the helper method to construct objects of the same type as the one given in argument.
	Use only the relevant attributes that are given, rather than all attributes."

	| model oldStatementBlock helper |
	model := visitor model.
	"swap visitor context: the 'sheet' on which the visitor writes"
	oldStatementBlock := visitor statementBlock.
	visitor statementBlock: model newStatementBlock.
	visitor builder processType: object type.
	"make the method entity"
	helper := self
		          makeMethodFor: object type
		          withParametersFor: attributes
		          on: visitor.
	"make the method body: instantiate object, set attributes and return it"
	visitor constructObject: object.
	self
		makeSetterInvocationsFor:
		(visitor filterAttributesToSet: attributes for: object type)
		on: visitor.
	visitor statementBlock addStatement:
		(model newReturnStatement expression:
			 (model newVariableExpression name: (visitor varNameFor: object))).
	"restore original visitor context"
	visitor statementBlock: oldStatementBlock.
	^ helper
]

{ #category : 'accessing' }
FamixValueHelperObjectExportStrategy >> currentDeclarations [

	^ currentDeclarations
]

{ #category : 'ast' }
FamixValueHelperObjectExportStrategy >> dependencyImportsOn: aFASTModel [

	^ declarations keys collect: [ :package |
		  (aFASTModel newImportDeclaration qualifiedName:
				   (aFASTModel newQualifiedName name: package , '.ModestHelper'))
			  isStatic: true;
			  isOnDemand: true ]
]

{ #category : 'exporting' }
FamixValueHelperObjectExportStrategy >> export: object on: visitor [
	"Use a helper method to instantiate the object and set its attributes."

	| attributes helper model |
	"ensure all relevant attributes are set up"
	(attributes := object relevantAttributes) do: [ :attribute |
		visitor ensureVisited: attribute value ].
	"check if the object was not set up in the previous step"
	(visitor varNameDict includesKey: object) ifTrue: [ ^ self ].

	"get the helper method, or build it if it does not exist"
	currentDeclarations := declarations
		                       at: (visitor helperPackageFor: object type)
		                       ifAbsentPut: [ Dictionary new ].
	helper := currentDeclarations
		          at: object constructorSignature
		          ifAbsentPut: [
			          self
				          buildMethodFor: object
				          withParametersFor: attributes
				          on: visitor ].

	"call the helper method to build the object and store it in a variable"
	model := visitor model.
	visitor statementBlock addStatement: (model newVarDeclStatement
			 type: (object asFASTJavaTypeExpressionOn: visitor);
			 addDeclarator: (model newVariableDeclarator
					  variable:
						  (model newVariableExpression name:
								   (visitor varNameFor: object));
					  expression:
						  (self
							   makeHelperInvocation: helper
							   arguments: attributes
							   on: visitor));
			 yourself)
]

{ #category : 'initialization' }
FamixValueHelperObjectExportStrategy >> initialize [

	helpers := Dictionary new
]

{ #category : 'exporting' }
FamixValueHelperObjectExportStrategy >> makeHelperInvocation: helper arguments: arguments on: visitor [

	| model |
	model := visitor model.
	^ model newMethodInvocation
		  name: helper name;
		  arguments: (arguments
				   with: helper parameters
				   collect: [ :argument :parameter | "reference the value with a variable"
					   | ref |
					   ref := visitor makeVariableExpression: argument value.
					   ((argument value type name sameAs: 'long') not and: [
							    (FASTJavaExportVisitor new export: parameter type) sameAs:
									    'long' ])
						   ifTrue: [ "try casting"
							   model newCastExpression
								   type: (model newClassTypeExpression typeName:
											    (model newTypeName name: 'long'));
								   expression: ref ]
						   ifFalse: [ ref ] ])
]

{ #category : 'ast' }
FamixValueHelperObjectExportStrategy >> makeHelpersOn: visitor [

	helpers keysAndValuesDo: [ :package :methodDeclarations |
		| helperClass |
		helperClass := visitor makeHelperInPackage: package.
		methodDeclarations do: [ :declaration |
			helperClass addDeclaration: declaration ] ]
]

{ #category : 'ast' }
FamixValueHelperObjectExportStrategy >> makeMethodFor: aFamixType withParametersFor: attributes on: visitor [
	"Make the method entity, handles its signature and modifiers."

	| model |
	model := visitor model.
	^ model newMethodEntity
		  name: 'new' , aFamixType baseName;
		  addModifier: (model newModifier token: 'public');
		  addModifier: (model newModifier token: 'static');
		  type: (aFamixType asFASTJavaTypeExpressionOn: visitor);
		  parameters: (attributes collect: [ :attribute |
					   model newParameter
						   type: (attribute attribute declaredType
								    ifNotNil: [ :declaredType |
									    attribute value type
										    decorate: declaredType
										    asFASTJavaTypeExpressionOn: visitor ]
								    ifNil: [
									    model newClassTypeExpression typeName:
											    (model newTypeName name: 'Object') ]);
						   variable:
							   (model newVariableExpression name: attribute varName) ]);
		  statementBlock: visitor statementBlock
]

{ #category : 'ast' }
FamixValueHelperObjectExportStrategy >> makeSetterInvocationsFor: attributes on: visitor [
	"Build the helper method's body: set the value of each argument to the corresponding attribute using setters or reflection."

	attributes do: [ :attribute |
		attribute attribute declaredType ifNotNil: [ :declaredType |
			visitor builder processType: declaredType ].

		(attribute object type findSetterOf: attribute attribute)
			ifNotNil: [ :setter |
				visitor
					makeSetterInvocation: setter
					for: attribute
					named: attribute varName ]
			ifNil: [ visitor makeReflectionSetterInvocation: attribute ] ]
]

{ #category : 'ast' }
FamixValueHelperObjectExportStrategy >> makeVariableExpression: value on: visitor [
	"Used when constructing an object to correctly name the argument variable.
	For helpers, the var name is the same as the helper method parameter."

	^ visitor model newVariableExpression name: value varName
]
