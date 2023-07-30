Class {
	#name : #FusedFuzzyGraph,
	#superclass : #FuzzyGraph,
	#instVars : [
		'fused'
	],
	#category : #CustomParsingVisualisation
}

{ #category : #'instance creation' }
FusedFuzzyGraph class >> with: anotherGraph [
	^ self new
	fused: anotherGraph;
	start: anotherGraph start;
	end: anotherGraph end;
	yourself.
]

{ #category : #adding }
FusedFuzzyGraph >> add: aNode ToFuseNode: aFuseNode [ 
	(aFuseNode internalNodes includes: aNode) ifTrue: [ 
		^''. "We should not re-add nodes"
	 ]ifFalse: [ 
		aFuseNode add: aNode. 
		aNode isFused ifFalse: [ nodesDict at: aNode id put: aFuseNode. ]
		ifTrue: [ 
			aNode internalNodes do: [ :internalNode|
				nodesDict at: internalNode id put: aFuseNode.
			].
		].
		nodes remove: aNode ifAbsent: [].
		aNode isStart ifTrue: [ self start: aFuseNode ].
		aNode isEnd ifTrue: [ self end: aFuseNode ].
	].
	
]

{ #category : #testing }
FusedFuzzyGraph >> canFuse: aLink [
	|aNode anotherNode|
	aNode := aLink nodeFrom.
	anotherNode := aLink nodeTo.
	anotherNode isEnd ifTrue: [ ^ false ]. "Never fuse with end since we want to not show it"
	aNode color = anotherNode color ifTrue: [
		(aNode linksFrom detect: [ :each | each label ~= aLink label ] ifNone: [ nil ]) ifNotNil: [ ^ false ] ifNil: [
			(aNode linksTo detect: [ :each | each label ~= aLink label ] ifNone: [ nil ]) ifNotNil: [ ^ false ] ifNil: [
				(anotherNode linksFrom detect: [ :each | each label ~= aLink label] ifNone: [ nil ]) ifNotNil: [ ^ false ] ifNil: [
					(anotherNode linksTo detect: [ :each | each label ~= aLink label] ifNone: [ nil ]) ifNotNil: [ ^ false ] ifNil: [ ^ true ]. ]] ]
		] ifFalse: [ ^ false ].
]

{ #category : #testing }
FusedFuzzyGraph >> canMaxFuse: aLink [
	|aNode anotherNode|
	aLink label = -1 ifTrue: [ ^ false ]. "Never fuse a red link"
	aNode := aLink nodeFrom.
	anotherNode := aLink nodeTo.
	anotherNode isEnd ifTrue: [ ^ false ].
	((aNode color = #red) or: (anotherNode color = #red)) ifTrue: [ ^ false ]. "Never fuse red nodes"
	anotherNode linksFrom do: [ :each | each label = -1 ifTrue: [ ^ false ]. each nodeTo color = #red ifTrue: [ ^false ]. "Never fuse nodes that have a red outlink -> Makes it crash !"
		each nodeTo linksFrom do: [ :secondLink | secondLink label = -1 ifTrue: [ ^ false ]. secondLink nodeTo color = #red ifTrue: [ ^false ].  ] ]. "Nor those that are linked to one"
	anotherNode linksTo do: [ :each | each label = -1 ifTrue: [ ^ false ]. each nodeFrom color = #red ifTrue: [ ^false ]. "Never fuse nodes that have a red inlink"
		each nodeFrom linksTo do: [ :secondLink | secondLink label = -1 ifTrue: [ ^ false ]. secondLink nodeFrom color = #red ifTrue: [ ^false ].  ] ]. "Nor those that are linked to one"
	aNode color = anotherNode color ifTrue: [ 
		aNode color = #green ifTrue: [ aLink label = 1 ifTrue: [ ^ true ] ifFalse: [ ^ false ] ].
		aNode color = #red ifTrue: [ aLink label = -1 ifTrue: [ ^ true ] ifFalse: [ ^ false ] ].
		aNode color = #orange ifTrue: [ aLink label = 0 ifTrue: [ ^ true ] ifFalse: [ ^ false ] ].
		aNode color = #gray ifTrue: [ aLink label = -2 ifTrue: [ ^ true ] ifFalse: [ ^ false ] ].
		].
	^ false.
	"aNode color = anotherNode color ifTrue: [
		(aNode linksFrom detect: [ :each | each label ~= aLink label ] ifNone: [ nil ]) ifNotNil: [ ^ false ] ifNil: [
				(anotherNode linksFrom detect: [ :each | each label ~= aLink label] ifNone: [ nil ]) ifNotNil: [ ^ false ] ifNil: [ ^ true ].  ]
		] ifFalse: [ ^ false ]."
]

{ #category : #'as yet unclassified' }
FusedFuzzyGraph >> fuse [
	fused := true.	
	[ fused ] whileTrue: [ 
		fused := false.
		self fuseRound: start processed: OrderedCollection new.
	].
]

{ #category : #'as yet unclassified' }
FusedFuzzyGraph >> fuse: round [	
	|temp|
	temp := round.
	[ temp ~= 0 ] whileTrue: [ 
		temp := temp - 1.
		self fuseRound: start processed: OrderedCollection new.
	].
]

{ #category : #'as yet unclassified' }
FusedFuzzyGraph >> fuseRound: aNode processed: nodesProcessed [
	|toFuse otherNode|
	toFuse := nil.
	aNode linksFrom do: [ :l | 
	l ifNotNil: [ 
		
	otherNode := l nodeTo.
	(self canMaxFuse: l) ifTrue: [
		aNode isFused ifTrue:[ self add: otherNode ToFuseNode: aNode. nodesProcessed add: otherNode. toFuse:= aNode.]
	                 ifFalse: [ 
							toFuse ifNil: [ 
							toFuse := FusedFuzzyGraphNode with: aNode.
							nodesDict at: aNode id put: toFuse.
							nodes remove: aNode ifAbsent: [].
							aNode = start ifTrue: [ start := toFuse ].
							self add:otherNode ToFuseNode: toFuse.
							nodesProcessed add: otherNode.
							nodes add: toFuse.
						] ifNotNil: [ 
							self add: otherNode ToFuseNode: toFuse.
							nodesProcessed add: otherNode.
							
						].
					]. fused := true.].
			].
	].
	nodesProcessed add: aNode.
	toFuse ifNil: [ 
		aNode linksFrom do: [ :each | 
			each ifNotNil: [(nodesProcessed includes: each nodeTo) ifFalse: [ self fuseRound: each nodeTo processed: nodesProcessed. ] ] ]]
	ifNotNil: [ 
		toFuse linksFrom do: [ :each | 
			each ifNotNil: [(nodesProcessed includes: each nodeTo) ifFalse: [ self fuseRound: each nodeTo processed: nodesProcessed ] ]] ].
]

{ #category : #'as yet unclassified' }
FusedFuzzyGraph >> fused: anObject [
	start := anObject start.
	nodes := anObject nodes.
	nodesDict := anObject nodesDict.
	
	
]

{ #category : #removing }
FusedFuzzyGraph >> removeDuplicate [
	nodes do: [ :eachNode|
		eachNode removeDuplicate.
		].
]
