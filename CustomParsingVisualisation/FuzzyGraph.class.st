Class {
	#name : #FuzzyGraph,
	#superclass : #Object,
	#instVars : [
		'start',
		'end',
		'nodes',
		'nodesDict',
		'fileContent'
	],
	#category : #CustomParsingVisualisation
}

{ #category : #'instance creation' }
FuzzyGraph class >> with: aFileContent [
	^ self new
	fileContent: aFileContent;
	nodes: OrderedCollection new;
	nodesDict: Dictionary new;
	extractContent;
	yourself.
]

{ #category : #'as yet unclassified' }
FuzzyGraph >> countLinks [
	|result|
	result := Dictionary new.
	self nodes do: [ : eachNode |
		eachNode linksFrom do: [ :each |
				result at: each label update: [ :value | value + 1 ] initial: [ 1 ].
				].
		eachNode linksTo do: [ :each |
				result at: each label update: [ :value | value + 1 ] initial: [ 1 ].
				].
	 ].
	^ result.
]

{ #category : #'creation - from string' }
FuzzyGraph >> createLinkFromString: aString [
	|idFrom idTo label nodeFrom nodeTo link|
	"Str format: idFrom -> idTo [label]"
	idFrom := (aString substrings) at: 1. "Arrays start at one"
	idTo := (aString substrings) at: 3.
	label := self extractNumber: ((aString substrings) at: 4).
	nodeFrom := self findNodeWithId: idFrom.
	nodeTo := self findNodeWithId: idTo.
	link := FuzzyGraphLink with: label from: nodeFrom to: nodeTo. 
	nodeFrom addLinkFrom: link.
	nodeTo addLinkTo: link.
	^ link
]

{ #category : #'creation - from string' }
FuzzyGraph >> createNodeFromString: aString [
	|id name matches|
	id := (aString substrings) at: 1. "Arrays start at one"
	name := self takeStr: aString Between: $[ and: $].
	matches := self takeStr: aString Between: $| and: $|.
	matches := matches substrings.
	^ FuzzyGraphNode with: id and:name matches: matches.
]

{ #category : #accessing }
FuzzyGraph >> end [
	^ end
]

{ #category : #accessing }
FuzzyGraph >> end: aNode [
	end := aNode
]

{ #category : #fileHandling }
FuzzyGraph >> extractContent [ 
	|nodeNext linkNext lastnode |
	nodeNext := false.
	linkNext := false.
	fileContent do: [ :each | 
		((each indexOfSubCollection: '->' startingAt: 1) > 0) ifTrue: [ linkNext := true ].
		linkNext ifTrue: [ |l|
			l := self createLinkFromString: each.
		].
		nodeNext ifTrue: [ |n|
			n := self createNodeFromString:each.
			nodes add: n. 
			nodeNext := false.
			nodesDict at: n id put: n.
			start ifNil: [ start := n. n isStart:true.]. "Set the start node"
			lastnode := n.
		].
		each = 'node' ifTrue: [nodeNext := true]. 
		].
		lastnode ifNotNil: [ end := lastnode. lastnode isEnd: true. ]
]

{ #category : #'creation - from string' }
FuzzyGraph >> extractNumber: aString [
	|re|
	re := '([^-\d]*)(-?\d*)(.*)' asRegexIgnoringCase.
	(re matchesPrefix: aString) ifTrue: [ ^ (re subexpression: 3) asNumber.]
										ifFalse: [ ^ nil ].
]

{ #category : #accessing }
FuzzyGraph >> fileContent: aString [
	fileContent := aString.
]

{ #category : #'as yet unclassified' }
FuzzyGraph >> findNodeId: aNumber [
	^ nodesDict at: aNumber
]

{ #category : #accessing }
FuzzyGraph >> findNodeWithId: aString [
	^ nodes detect: [ :each | (each id) = aString ].
	
]

{ #category : #testing }
FuzzyGraph >> hasNode: aNode [
	^ nodes includes: aNode
]

{ #category : #accessing }
FuzzyGraph >> nodes [
	^ nodes
]

{ #category : #accessing }
FuzzyGraph >> nodes: anObject [
	nodes := anObject 
]

{ #category : #accessing }
FuzzyGraph >> nodesDict [
	^ nodesDict 
]

{ #category : #accessing }
FuzzyGraph >> nodesDict: anObject [
	nodesDict := anObject 
]

{ #category : #accessing }
FuzzyGraph >> start [
	^ start
]

{ #category : #accessing }
FuzzyGraph >> start: aNode [
	start := aNode
]

{ #category : #'creation - from string' }
FuzzyGraph >> takeStr: aString Between: aChar and: anotherChar [
	|result go|
	go := false.
	result := ''.
	(1 to: (aString size)) do: [ :index | 
		go ifTrue: [ "We are extracting"
			(aString at: index) = anotherChar ifTrue: [ ^ result ]
			ifFalse: [ result := result,((aString at:index) asString)] 
		]
		ifFalse: [ 
			(aString at: index) = aChar ifTrue: [ go := true ]
		].
	].
	^ result
]
