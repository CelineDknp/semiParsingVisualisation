Class {
	#name : #FusedFuzzyGraphNode,
	#superclass : #FuzzyGraphNode,
	#instVars : [
		'internalNodes',
		'initialLinksFrom',
		'initialLinksTo'
	],
	#category : #CustomParsingVisualisation
}

{ #category : #'instance creation' }
FusedFuzzyGraphNode class >> with: aNode [
	^ self new
	isStart: false;
	isEnd: false;
	internalNodes: OrderedCollection new;
	initialLinksFrom: Dictionary new;
	initialLinksTo: Dictionary new;
	matchGroup: Set new;
	add: aNode;
	yourself.
]

{ #category : #'instance creation' }
FusedFuzzyGraphNode class >> with: aNode and: anotherNode [
	^ self new
	isStart: false;
	isEnd: false;
	internalNodes: OrderedCollection new;
	initialLinksFrom: Dictionary new;
	initialLinksTo: Dictionary new;
	matchGroup: Set new;
	add: aNode;
	add: anotherNode;
	yourself.
]

{ #category : #adding }
FusedFuzzyGraphNode >> add: aNode [
	| toRemove tempRemove|
	self linksFrom ifNil: [ ^ self copyNode: aNode ].
	toRemove := OrderedCollection new.
	tempRemove := OrderedCollection new.
	self addNode: aNode.
	linksFrom do: [ :each|
		each nodeFrom ~= self ifTrue: [ ((each nodeTo = self) or: (self pointInside: each nodeTo)) ifTrue: [ toRemove add: each. tempRemove add: each. ] "Found a link that needs removal"
					ifFalse: [ each nodeFrom: self]. "Set the link to the correct node"
			 ]	ifFalse: [ 
				(self pointInside: each nodeTo) ifTrue: [ toRemove add: each. tempRemove add: each.  ].
			 ].
		"each nodeTo linksTo do: [ :eachLink | (self pointInside: eachLink nodeFrom) ifTrue: [ eachLink nodeFrom: self ] ]."
	].
	tempRemove do: [ :each | linksFrom remove: each ].
	toRemove addAll: (self cleanUpLinks: linksFrom).
	tempRemove := OrderedCollection new.
	linksTo do: [ :each|
		each nodeTo ~= self ifTrue: [ ((each nodeFrom = self) or: (self pointInside: each nodeFrom)) ifTrue: [ toRemove add: each. tempRemove add: each. ] "Found a link that needs removal"
					ifFalse: [ each nodeTo: self]. "Set the link to the correct node"
			 ]	ifFalse: [ 
				(self pointInside: each nodeFrom) ifTrue: [ toRemove add: each. tempRemove add: each.  ].
			 ].
		"each nodeFrom linksFrom do: [ :eachLink | (self pointInside: eachLink nodeTo) ifTrue: [ eachLink nodeTo: self ] ]."
	].
	tempRemove do: [ :each | linksTo remove: each ].
	toRemove addAll: (self cleanUpLinks: linksTo).
	^ toRemove
]

{ #category : #adding }
FusedFuzzyGraphNode >> addNode: aNode [
	aNode isStart ifTrue: [ isStart := true ].
	aNode isEnd ifTrue: [ isEnd := true ].
	aNode isFused ifFalse: [ 
			self processNode: aNode.
		] ifTrue: [ 
			self internalNodes addAll: aNode internalNodes. "Add all internal nodes"
			self linksFrom addAll: aNode linksFrom.
			self linksTo addAll: aNode linksTo.
		].
]

{ #category : #'as yet unclassified' }
FusedFuzzyGraphNode >> cleanUpLinks: aLinkList [
	| test removeTotal |
	test := OrderedCollection new.
	removeTotal := OrderedCollection new.
	removeTotal := aLinkList collect: [ :each | (each nodeTo = each nodeFrom) ].

	"aLinkList do: [ :each|
		|val|
		val := Array with: each nodeFrom with: each nodeTo.
		(allCouple includes: val) ifTrue: [ 
			(remove includes: each) ifFalse: [ remove add: each ]. Remove if found already and if not to be removed
		 ] ifFalse: [ 
			allCouple add: val.
		 ]
	]."
	
	^ removeTotal
]

{ #category : #adding }
FusedFuzzyGraphNode >> copyAndAdd: aLinkList to: aSide [
	|list|
	list := OrderedCollection new.
	aLinkList do: [ :each | list add: (self copyLink: each) ].
	aSide = 'from' ifTrue: [ linksFrom addAll: list ] ifFalse: [ linksTo addAll: list ].
]

{ #category : #copying }
FusedFuzzyGraphNode >> copyLink: aLink [
	|result|
	result  := FuzzyGraphLink with: aLink label from: aLink nodeFrom to: aLink nodeTo.
	^ result.
]

{ #category : #copying }
FusedFuzzyGraphNode >> copyNode: aNode [
	linksFrom := OrderedCollection new.
	linksTo := OrderedCollection new.
	self processNode: aNode.
	text := 'Fused'.
	color := aNode color.
	id := 'F', aNode id. 
	aNode isStart ifTrue: [ isStart := true ].
	aNode isEnd ifTrue: [ isEnd := true ].
]

{ #category : #accessing }
FusedFuzzyGraphNode >> initialLinksFrom [
	^initialLinksFrom
]

{ #category : #accessing }
FusedFuzzyGraphNode >> initialLinksFrom: anObject [
	initialLinksFrom := anObject
]

{ #category : #accessing }
FusedFuzzyGraphNode >> initialLinksTo [
	^initialLinksTo
]

{ #category : #accessing }
FusedFuzzyGraphNode >> initialLinksTo: anObject [
	initialLinksTo := anObject
]

{ #category : #adding }
FusedFuzzyGraphNode >> internalNodes [
	^internalNodes 
]

{ #category : #adding }
FusedFuzzyGraphNode >> internalNodes: anObject [
	internalNodes := anObject 
]

{ #category : #testing }
FusedFuzzyGraphNode >> isFused [
	^ true
]

{ #category : #accessing }
FusedFuzzyGraphNode >> label [
	^ 'FUSED ' , (internalNodes size) asString.
]

{ #category : #'as yet unclassified' }
FusedFuzzyGraphNode >> pointInside: aNode [
	aNode isFused ifTrue: [ 
		aNode internalNodes do: [ :each | (self internalNodes includes: each) ifTrue: [ ^ true ] ].
		^ false.
	] ifFalse: [ 
		^ internalNodes includes: aNode.
	].
]

{ #category : #printing }
FusedFuzzyGraphNode >> printOn: aStream [
	<category: 'printing'>
   id printOn: aStream.
   internalNodes size printOn: aStream.
   aStream nextPutAll: ' ('.
   internalNodes  printOn: aStream.
   aStream nextPutAll: ')'.
]

{ #category : #'equivalence classes' }
FusedFuzzyGraphNode >> processNode: aNode [
	(internalNodes includes: aNode) ifTrue: [ ^ self ].
	internalNodes add: aNode. "Only add if node is not in there yet"
	self linksFrom addAll: aNode linksFrom.
	self linksTo addAll: aNode linksTo.
	self matchGroup addAll: aNode matchGroup.
	self saveLinks: aNode
]

{ #category : #adding }
FusedFuzzyGraphNode >> saveLinks: aNode [
	|list|
	list := OrderedCollection new.
	aNode linksFrom  do: [ :each | list add: (self copyLink: each) ].
	aNode linksFrom: list.
	list := OrderedCollection new.
	aNode linksTo  do: [ :each | list add: (self copyLink: each) ].
	aNode linksTo: list.
]
