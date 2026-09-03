Extension { #name : 'FASTJavaIdentifier' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaIdentifier >> staticTypeIn: executable with: loader [

	^ loader staticTypeOfName: self name in: executable
]
