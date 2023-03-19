Class {
	#name : #BaselineOfFamixValue,
	#superclass : #BaselineOf,
	#category : #BaselineOfFamixValue
}

{ #category : #baselines }
BaselineOfFamixValue >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		self defineDependencies: spec.
		self definePackages: spec.
		self defineGroups: spec ]
]

{ #category : #baselines }
BaselineOfFamixValue >> defineDependencies: spec [

	spec baseline: 'FASTJava' with: [ 
		spec
			loads: #( 'visitor' );
			repository: 'github://moosetechnology/FAST-Java:v3/src' ]
]

{ #category : #baselines }
BaselineOfFamixValue >> defineGroups: spec [

	spec
		group: 'default' with: #( 'model' 'importer' );
		group: 'model'
		with: #( 'Famix-Value-Entities' 'Famix-Value-Entities-Extensions'
			   'Famix-Value-Generator' );
		group: 'importer' with: #( 'Famix-Value-Importer' );
		group: 'exporter'
		with:
			#( 'default' 'Famix-Value-Exporter' 'Famix-Value-Exporter-Tests'
			   'FASTJava' )
]

{ #category : #baselines }
BaselineOfFamixValue >> definePackages: spec [

	spec
		package: 'Famix-Value-Entities';
		package: 'Famix-Value-Entities-Extensions'
		with: [ spec requires: #( 'Famix-Value-Entities' ) ];
		package: 'Famix-Value-Generator';
		package: 'Famix-Value-Importer';
		package: 'Famix-Value-Exporter';
		package: 'Famix-Value-Exporter-Tests'
		with: [ spec requires: #( 'Famix-Value-Exporter' ) ]
]
