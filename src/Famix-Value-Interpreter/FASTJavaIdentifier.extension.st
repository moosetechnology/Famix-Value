Extension { #name : 'FASTJavaIdentifier' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaIdentifier >> staticTypeIn: methodInfo with: loader [

	^ loader staticTypeOfName: self name in: methodInfo
]
