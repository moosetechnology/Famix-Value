Class {
	#name : #BaselineOfFamixValue,
	#superclass : #BaselineOf,
	#category : #BaselineOfFamixValue
}

{ #category : #baselines }
BaselineOfFamixValue >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		spec
			package: 'Famix-Value-Entities';
			package: 'Famix-Value-Entities-Extensions'
			with: [ spec requires: #( 'Famix-OpenTelemetry-Entities' ) ];
			package: 'Famix-Value-Generator';
			package: 'Famix-Value-Importer' ]
]
