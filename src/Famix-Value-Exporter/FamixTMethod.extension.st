Extension { #name : 'FamixTMethod' }

{ #category : '*Famix-Value-Exporter' }
FamixTMethod >> allAccessedAttributes [

	^ self cacheAt: #allAccessedAttributes ifAbsentPut: [
		  self
			  allAccessedAttributesOn: OrderedCollection new
			  seen: IdentitySet new ]
]

{ #category : '*Famix-Value-Exporter' }
FamixTMethod >> allAccessedAttributesOn: collection seen: seen [

	(seen includes: self) ifTrue: [ ^ collection ].
	seen add: self.
	accesses do: [ :access |
		access variable isAttribute ifTrue: [
			collection add: access variable ] ].
	outgoingInvocations do: [ :invoc |
		invoc candidates size > 1 ifTrue: [
			self halt "how to choose correct one?" ].
		invoc candidates first
			allAccessedAttributesOn: collection
			seen: seen
		"invoc candidates first isSetter ifTrue: [ 
			invoc candidates first accesses
				detect: [ :access | access variable isAttribute ]
				ifOne: [ :access | collection add: access variable ]
				ifNone: [ NotFound signal ] ]" ].
	^ collection
]

{ #category : '*Famix-Value-Exporter' }
FamixTMethod >> constructorScore [
	"Arbitrary score to evaluate the effectiveness of a constructor."

	| parameterCount |
	parameterCount := parameters size.
	^ parameterCount = 0
		  ifTrue: [ "For now (11/23), favor using the empty constructor if available. Finding the best constructor is not easy, currently it's just based on parameter count and attribute **access** count (we don't even check if it's a write and not just a read)."
			  Float infinity ]
		  ifFalse: [
		  parameterCount * self allAccessedAttributes size / parameterCount ]
]

{ #category : '*Famix-Value-Exporter' }
FamixTMethod >> mapConstructorParametersToAttributes [
	"Return the list of the attribute set by each of my parameters, e.g. if I were:
	MyClass(int theFoo, String someBar) { this.foo = theFoo; setBar(someBar); }
	then I'd return: { MyClass.foo. MyClass.bar }"

	self generateFastIfNotDoneAndBind.
	^ parameters collect: [ :parameter |
		  (parameter fastAccesses flatCollectAsSet: [ :access |
			   access accessedAttributesOf: parentType ])
			  ifNotEmpty: [ :attributes |
				  | attribute |
				  attributes size = 1 ifFalse: [
					  FamixValueExporterError signal: 'Expected only one attribute.' ].
				  (attribute := attributes anyOne) declaredType
					  ifNil: [ "TODO should not happen, fix Java parser" nil ]
					  ifNotNil: [ :attributeType |
						  (attributeType withSubHierarchy includes:
							   parameter declaredType)
							  ifTrue: [ attribute ]
							  ifFalse: [ "parameter is used to set the attribute, but not directly because they are of different types
						a common occurence is an array-to-collection transformation:
						setValues(String... values) { this.values = Arrays.asList(values); }
						however reality is often more complex, so for now we ignore this parameter-to-attribute mapping (10/24)"
								  nil ] ] ]
			  ifEmpty: [ "parameter is not mapped to an attribute" nil ] ]
]
