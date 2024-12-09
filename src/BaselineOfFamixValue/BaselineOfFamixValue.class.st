Class {
	#name : 'BaselineOfFamixValue',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfFamixValue',
	#package : 'BaselineOfFamixValue'
}

{ #category : 'baselines' }
BaselineOfFamixValue >> baseline: spec [

	<baseline>
	spec for: #common do: [
		self dependencies: spec.
		self packages: spec.
		self groups: spec ]
]

{ #category : 'baselines' }
BaselineOfFamixValue >> dependencies: spec [

	spec
		baseline: 'FASTJava' with: [
			spec
				repository: 'github://moosetechnology/FAST-JAVA:v3/src';
				loads: 'tools' ];
		baseline: 'Carrefour'
		with: [
		spec repository: 'github://moosetechnology/Carrefour:v5/src' ]
]

{ #category : 'baselines' }
BaselineOfFamixValue >> groups: spec [

	spec
		group: 'default' with: #( 'model' 'importer' 'exporter' );
		group: 'model'
		with: #( 'Famix-Value-Entities' 'Famix-Value-Entities-Extensions'
			   'Famix-Value-Generator' 'Famix-Value-Presenter' );
		group: 'importer'
		with: #( 'Famix-Value-Importer' 'Famix-Value-Types' );
		group: 'exporter'
		with:
			#( 'default' 'Famix-Value-Exporter' 'Famix-Value-Exporter-Tests'
			   'FASTJava' 'Carrefour' )
]

{ #category : 'baselines' }
BaselineOfFamixValue >> packages: spec [

	spec
		package: 'Famix-Value-Entities';
		package: 'Famix-Value-Entities-Extensions'
		with: [ spec requires: 'Famix-Value-Entities' ];
		package: 'Famix-Value-Generator';
		package: 'Famix-Value-Importer'
		with: [
			spec requires: #( 'Famix-Value-Entities' 'Famix-Value-Types' ) ];
		package: 'Famix-Value-Exporter'
		with: [
			spec requires: #( 'Famix-Value-Entities' 'Famix-Value-Types' ) ];
		package: 'Famix-Value-Exporter-Tests'
		with: [ spec requires: 'Famix-Value-Exporter' ];
		package: 'Famix-Value-Types';
		package: 'Famix-Value-Presenter'
		with: [ spec requires: 'Famix-Value-Entities' ]
]
