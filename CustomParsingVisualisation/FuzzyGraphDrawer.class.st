"
Class responsible of drawing the visualisation of trace equivalenced graphs.
Called when the user clicks on a file in the list of files in the main visualisation form.
(Called from `connectPresenter` in _CustomFuzzyPresenterForm_).

Instanciation: `FuzzyGraphDrawer with: aFileName and: aDirectoryTarget`
(Directory must contain two files named filename_V1.COB and filename_V2.COB)

Instance Variables
- **canvas**:	A RSCanvas on which to draw (+ `canvas:`)
- **filename**: The String name of the file we are interested in (+ `filename:`)
- **targetPath**: The String path towards the directory containing the trace equivalenced version of filename

Implementation Points
- `open`: Opens the **canvas** to show the drawing
- `processFiles`: Opens the necessary files from **targetPath** and extracts their content
"
Class {
	#name : #FuzzyGraphDrawer,
	#superclass : #Object,
	#instVars : [
		'filename',
		'targetPath',
		'canvas',
		'g1',
		'g2',
		'fusedG1',
		'fusedG2',
		'nodeMap',
		'legend',
		'finalG1',
		'finalG2'
	],
	#category : #CustomParsingVisualisation
}

{ #category : #'instance creation' }
FuzzyGraphDrawer class >> with: aString and: anotherString [
	^ self new
	filename: aString;
	targetPath: anotherString;
	canvas: RSCanvas new;
	nodeMap: Dictionary new;
	yourself
]

{ #category : #adding }
FuzzyGraphDrawer >> addDeadCodeSelector: aCanvas [
	|labels update |
	labels := #('Show dead code' 'Hide dead code').
	update := [ :sel | 
		(sel = 'Show dead code')
			ifTrue: [ self drawEverythingOn: aCanvas hideDead: false. ].
		(sel = 'Hide dead code')
			ifTrue: [ self drawEverythingOn: aCanvas hideDead: true. ].
		 ].
	labels := labels collect: [ :sel |
		RSLabel new
			isFixed: true;
			text: sel capitalized;
			when: RSMouseLeave do: [ :evt | evt shape 
				color: Color gray; 
				normal;
				signalUpdate ];
			when: RSMouseEnter do: [ :evt | evt shape 
				color: Color blue; 
				underline;
				signalUpdate ];
			when: RSMouseClick do: [ :evt | 
				update value: sel.
				aCanvas zoomToFit. ] ].
	aCanvas addAll: labels.
	RSHorizontalLineLayout on: labels.
]

{ #category : #adding }
FuzzyGraphDrawer >> addLegend: aCanvas [
	|endNode border|
	legend := RSLegend new.
	legend title: 'Color code'.
	legend 	text: 'Matched' withBoxColor: Color green;
				text: 'Unmatched' withBoxColor: Color red;
				text: 'Skipped' withBoxColor: Color orange;
				text: 'Unexplored' withBoxColor: Color gray;
				text: 'Perfect match' withBoxColor: Color blue;
				text: 'Group match' withBoxColor: (Color blue alpha: 0.3).
	border := RSBorder new.
				border width:3.
	endNode := RSEllipse new color: Color white; border: border; borderColor: #black.
	legend text: 'Node linked to END node' withShape: endNode.
				"text: 'Line width indicates change weight'."
	legend legendDo: [ :l | l withBorder; padding: 60 ].
	legend layout horizontal gapSize: 20.
	legend location bottom.
	legend container: aCanvas.
	legend build.
]

{ #category : #'as yet unclassified' }
FuzzyGraphDrawer >> baseHighlight: aGraph withOther: otherGraph [
	|interaction selectedItems highlitedItems interaction2|
	
	selectedItems := OrderedCollection new.
	highlitedItems := OrderedCollection new.
	
	interaction := RSHighlightable new withLines.
	interaction2 := RSHighlightable new withLines.
	interaction highlightColor: (Color blue).
	interaction2 highlightColor: (Color blue alpha: 0.3).
	self highlightOnMouseOver: interaction other: interaction2 graph1: aGraph graph2: otherGraph.
	interaction := RSHighlightable new withLines.
	interaction2 := RSHighlightable new withLines.
	interaction highlightColor: (Color blue).
	interaction2 highlightColor: (Color blue alpha: 0.3).
	self highlightOnClick: interaction other: interaction2 graph1: aGraph graph2: otherGraph.
]

{ #category : #accessing }
FuzzyGraphDrawer >> canvas: anObject [
	canvas := anObject
]

{ #category : #'processing files' }
FuzzyGraphDrawer >> colorGraph: aGraph [
	aGraph start color: #green.
	aGraph nodes do:[:eachNode|
		eachNode linksFrom do: [ :each |
			self colorNode: each nodeFrom withLabel: each. 
		].
		eachNode linksFrom isEmpty ifTrue: [ "Special case for end nodes"
			eachNode linksTo do: [ :aLabel |
				aLabel label = 1 ifTrue: [ 
				eachNode color ~= Color red ifTrue: [ "We need to color this node"
					eachNode color: #green
				].
				] ifFalse: [ 
					aLabel label = 0 ifTrue: [ eachNode color: #orange ]
					ifFalse: [ aLabel label = -1 ifTrue: [ eachNode color: #red ]]].
			].
		 ].
		"eachNode matchGroup isNotEmpty ifTrue: [ eachNode color: #green ]"
	].
	
	
]

{ #category : #'processing files' }
FuzzyGraphDrawer >> colorGraphs [ 
	self colorGraph: g1.
	self colorGraph: g2.
]

{ #category : #drawing }
FuzzyGraphDrawer >> colorNode: aNode withLabel: aLabel [
	aLabel label = 1 ifTrue: [ 
		aNode color ~= #red ifTrue: [ "We need to color this node"
			aNode color: #green
	].
	] ifFalse: [ 
		aLabel label = 0 ifTrue: [ aNode color: #orange ]
		ifFalse: [ 	
				aLabel label = -1 ifTrue: [ aNode color: #red ]]].
	
]

{ #category : #'as yet unclassified' }
FuzzyGraphDrawer >> drawEverythingOn: aCanvas hideDead: aBoolean [
	| dead1 dead2 nodesG1 nodesG2 allShapesG1 allShapesG2 bothGraphs|
	self resertCanvas: aCanvas.
	fusedG1 ifNotNil: [ fusedG1 removeDuplicate. finalG1 := fusedG1] ifNil: [ finalG1 := g1 ].
	fusedG2 ifNotNil: [ fusedG2 removeDuplicate. finalG2 := fusedG2] ifNil: [ finalG2 := g2 ].
	aBoolean ifTrue: [  
		dead1 := self removeDeadNodes: finalG1 nodes.
		dead2 := self removeDeadNodes: finalG2 nodes.
		nodesG1 := (finalG1 nodes copy).
		nodesG1 removeAll: dead1.
		nodesG2 := (finalG2 nodes copy).
		nodesG2 removeAll: dead2.
		] 
		ifFalse: [ nodesG1 := finalG1 nodes copy. nodesG2  := finalG2 nodes copy.].
	allShapesG1 := self drawFullGraph: nodesG1 start: finalG1 start on: aCanvas.
	allShapesG2 := self drawFullGraph: nodesG2 start: finalG2 start on: aCanvas.
	bothGraphs := RSGroup with: allShapesG1 with: allShapesG2.
	RSCellLayout new gapSize: 50; on: bothGraphs.
	self baseHighlight: finalG1 withOther: finalG2.
	aCanvas @ RSCanvasController.
	self addLegend: aCanvas.
	self addDeadCodeSelector: aCanvas.
	aCanvas zoomToFit.
]

{ #category : #drawing }
FuzzyGraphDrawer >> drawFullGraph: aGraph on: aCanvas [
	|allShapes layout edges start end al rightmost bottommost |
	allShapes := aGraph nodes collect: [ :each |
		|result|
			each isEnd ifFalse: [ 
				result :=	 self drawSingleNode: each.
				aCanvas add: result.
				nodeMap at: each put: result.
				result.].
	].
	allShapes removeAllSuchThat: [ :each| each isNil ].
	allShapes := allShapes as: RSGroup.
	edges := aGraph nodes collect: [ :eachNode |
		eachNode linksFrom do: [ :each |
			|result|
			(each nodeFrom isEnd or: each nodeTo isEnd) ifFalse: [ 
			result := (self drawSingleLink: each with: nodeMap).		
			aCanvas add: result.
			result.].
			].
	].
	layout := RSCircleLayout new.
	layout on: allShapes.
	"layout := RSForceBasedLayout new.
	layout on: allShapes."
	layout := RSTreeLayout new.
	layout horizontalGap: 50.
	layout verticalGap: 50.
	layout on: allShapes.
	start := self findEquivalentShape: aGraph start.
	start position: 0@0.
	"end := self findEquivalentShape: aGraph end.
	al := RSAlignment new shapes: allShapes.
	rightmost := al rightMostShape position.
	bottommost := al bottomMostShape position.
	end position: (rightmost x+20)@(bottommost y+20)."
	^ allShapes.
]

{ #category : #drawing }
FuzzyGraphDrawer >> drawFullGraph: nodes start: startNode on: aCanvas [
	|allShapes layout edges start|
	allShapes := nodes collect: [ :each |
		|result|
			each isEnd ifFalse: [ 
				result :=	 self drawSingleNode: each.
				aCanvas add: result.
				nodeMap at: each put: result.
				result.].
	].
	allShapes removeAllSuchThat: [ :each| each isNil ].
	allShapes := allShapes as: RSGroup.
	edges := nodes collect: [ :eachNode |
		eachNode linksFrom do: [ :each |
			|result|
			(each nodeFrom isEnd or: each nodeTo isEnd) ifFalse: [ 
			result := (self drawSingleLink: each with: nodeMap).		
			aCanvas add: result.
			result.].
			].
	].
	layout := RSCircleLayout new.
	layout on: allShapes.
	"layout := RSForceBasedLayout new.
	layout on: allShapes."
	layout := RSTreeLayout new.
	layout horizontalGap: 50.
	layout verticalGap: 50.
	layout on: allShapes.
	start := self findEquivalentShape: startNode.
	start position: 0@0.
	"end := self findEquivalentShape: aGraph end.
	al := RSAlignment new shapes: allShapes.
	rightmost := al rightMostShape position.
	bottommost := al bottomMostShape position.
	end position: (rightmost x+20)@(bottommost y+20)."
	^ allShapes.
]

{ #category : #drawing }
FuzzyGraphDrawer >> drawInternalGraph: aNode on: aCanvas [
	|map allShapes layout |
	map := Dictionary new.
	allShapes := aNode internalNodes collect: [ :each |
		|result|
			result :=	 self drawSingleNode: each.
			aCanvas add: result.
			map at: each put: result.
			result.
	] as: RSGroup.
	aNode internalNodes do: [ :n | n linksFrom do: [ :each |
		(aNode internalNodes includes: each nodeTo) ifTrue: [ 
			aCanvas add: (self drawSingleLink: each with: map).		
		].
	]].
	layout := RSTreeLayout new.
	layout horizontalGap: 50.
	layout verticalGap: 50.
	layout on: allShapes.
	^ allShapes.
]

{ #category : #drawing }
FuzzyGraphDrawer >> drawSingleLink: aLink with: aDictionary [
	|result arrow interaction shapeFrom shapeTo|
	arrow := RSPolygon new 
      			points: { -10@0. 0@ -10. 10@0 };
      			size: 15.
	shapeFrom := aDictionary at: aLink from.
	shapeTo := aDictionary at: aLink to.
	result := RSArrowedLine new from: shapeFrom ;
										to: shapeTo .
	"self colorNode: shapeFrom withLabel: aLink label.
	self colorNode: shapeTo withLabel: aLink label."
	result markerEnd: arrow.
	result markerEnd offset: 6.
	result attachPoint: RSBorderAttachPoint new.
	result model: aLink label.
	aLink label = -1 ifTrue: [ result color: #red ].
	aLink label = 0 ifTrue: [ result color: #orange ].
	aLink label = 1 ifTrue: [ result color: #green ].
	result @RSPopup.
		
	interaction := RSHighlightable new.
	interaction highlightColor: Color black.
	canvas edges @ interaction.
	^ result.
]

{ #category : #drawing }
FuzzyGraphDrawer >> drawSingleNode: aNode [
	| node nodeSize|
	node := aNode isEnd
		        ifTrue: [ RSBox new ]
		        ifFalse: [ 
			        aNode isStart
				        ifTrue: [ 
					        RSPolygon new points: { 
							        (40 @ 0).
							        (0 @ 0).
							        (20 @ 20) } ]
				        ifFalse: [ RSEllipse new ] ].
	node
		draggable;
		color: aNode color;
		size: 40;
		model: aNode detailedLabel.
	"aNode isFused ifTrue: [ node size: 60 ]. Bugs with only the other thig, weird"
	(aNode linksFrom anySatisfy: [ :link| link nodeTo isEnd ]) ifTrue: [ |border|
				border := RSBorder new.
				border width:3.
				node border: border.
				node borderColor: #black ].
	node @ (RSLabeled new text: aNode label).
	node @ RSDraggable.
	node @ RSPopup.
	aNode isFused ifTrue: [ 
		| test |
		test := RSInspectableInteraction new.
		test inspectShapeBlock: [ :input | 
			| builder |
			builder := RSCanvas new.
			self drawInternalGraph: aNode on: builder.
			builder @ RSCanvasController.
			builder open ].
		node @ test ].
	^ node
]

{ #category : #accessing }
FuzzyGraphDrawer >> filename: aString [ 
	filename := aString 
]

{ #category : #'as yet unclassified' }
FuzzyGraphDrawer >> findEquivalentNode: aShape [
	nodeMap associationsDo: [ :pair |
		pair value = aShape ifTrue: [ ^ pair key ]
	 ].
	^ nil.
]

{ #category : #'as yet unclassified' }
FuzzyGraphDrawer >> findEquivalentShape: aNode [
	^nodeMap at: aNode ifAbsent: [ nil ]
]

{ #category : #'as yet unclassified' }
FuzzyGraphDrawer >> findEquivalentShapeWithId: aNumber in: aGraph [
	|corrNode|
	corrNode := aGraph findNodeId: aNumber.
	corrNode ifNil: [ 
		^ nil ].
	^nodeMap at: corrNode ifAbsent: [ ^nil ]
]

{ #category : #accessing }
FuzzyGraphDrawer >> findGroupShape: shape in: aGraph or: otherGraph [

	| corrNode corrShapes corrGraph otherCorrGraph otherNode|
	corrNode := self findEquivalentNode: shape.
	corrGraph := (aGraph hasNode: corrNode)
		             ifTrue: [ otherGraph ]
		             ifFalse: [ aGraph ].
	otherCorrGraph := (aGraph hasNode: corrNode)
		             ifTrue: [ aGraph ]
		             ifFalse: [ otherGraph ].
	corrShapes := corrNode matchGroup collect: [ :nodeID | 
		              self findEquivalentShapeWithId: nodeID in: corrGraph ].
	corrShapes := corrShapes asOrderedCollection.
	corrShapes ifNotEmpty: [ 
		otherNode := self findEquivalentNode: corrShapes anyOne.
		otherNode matchGroup do: [ :nodeID | |currShape|
			currShape := self findEquivalentShapeWithId: nodeID in: otherCorrGraph. (currShape = shape) ifFalse: [ 		corrShapes add: currShape. ]. ].
	].
	corrShapes removeAllSuchThat: [ :elem| elem isNil ].
	corrShapes := corrShapes asSet.
	^ corrShapes as: RSGroup.
]

{ #category : #'as yet unclassified' }
FuzzyGraphDrawer >> fuse1: round [
	fusedG1 := FusedFuzzyGraph with: g1.
	fusedG1 fuse: round.
]

{ #category : #'as yet unclassified' }
FuzzyGraphDrawer >> fuse2: round [
	fusedG2 := FusedFuzzyGraph with: g2.
	fusedG2 fuse: round.
]

{ #category : #'as yet unclassified' }
FuzzyGraphDrawer >> fuseBoth [
	fusedG1 := FusedFuzzyGraph with: g1.
	fusedG2 := FusedFuzzyGraph with: g2.
	fusedG1 fuse.
	fusedG2 fuse.
]

{ #category : #accessing }
FuzzyGraphDrawer >> g1 [
	^ g1
]

{ #category : #accessing }
FuzzyGraphDrawer >> g2 [
	^ g2
]

{ #category : #testing }
FuzzyGraphDrawer >> hasPerfectMatch: aNode in: aGroupOfShape [
	aNode isFused ifTrue: [ ^ nil. ].
	aNode color = #green ifTrue: [ 
		(aNode text includes: 'IF') ifTrue: [ ^ aGroupOfShape ].
		aGroupOfShape do: [ :each | |temp| 
			temp := self findEquivalentNode: each. 
			temp isFused ifTrue: [ 
				temp internalNodes do: [ :inNode| temp text = aNode text ifTrue: [ 
						^ each
						] ].
			] 
			ifFalse: [ 
				temp text = aNode text ifTrue: [ ^each]
			].
		].
	 ].
	^ nil
]

{ #category : #'as yet unclassified' }
FuzzyGraphDrawer >> highlightOnClick: baseInteraction other: otherInteraction graph1: aGraph graph2: otherGraph [
	|selectedBaseItems selectedGroupItems|
	selectedBaseItems := OrderedCollection new.
	selectedGroupItems := OrderedCollection new.
	
	canvas nodes
		when: RSMouseLeftClick do: [ :evt | | shape concreteNode corrShapes perfectMatch|
			shape := evt shape.
				shape class = RSLabel ifFalse: [ 
				concreteNode := self findEquivalentNode: shape.
				corrShapes := self findGroupShape: shape in: aGraph  or: otherGraph.
				perfectMatch := self hasPerfectMatch: concreteNode in: corrShapes.
				perfectMatch ifNil: [ 
					corrShapes add: shape. "Adding the node itself to highlight"
					corrShapes do: [ :each| (selectedBaseItems includes: each) ifFalse: [ selectedGroupItems add: each ]. ].
					"selectedGroupItems addAll: corrShapes."
					selectedGroupItems  := selectedGroupItems as: RSGroup.
					otherInteraction doHighlightShapes: selectedGroupItems.
					baseInteraction doHighlightShapes: selectedBaseItems.
				] ifNotNil: [ 
					"Remove all from corrshape except perfect"
					corrShapes removeAllSuchThat: [ :elem | elem ~= perfectMatch ]. 
					corrShapes add: shape.
					selectedBaseItems := corrShapes.
					baseInteraction doHighlightShapes: selectedBaseItems.
					otherInteraction doHighlightShapes: selectedGroupItems.
				].].
			evt signalUpdate.
	].
	canvas
		when: RSMouseClick do: [ :evt | 
			evt shape class = RSLabel ifFalse: [ 
			selectedBaseItems removeAll.
			selectedGroupItems removeAll.
			baseInteraction unhighlightRecordedShapes: evt.
			otherInteraction unhighlightRecordedShapes: evt.
			].
			evt signalUpdate ].
]

{ #category : #'as yet unclassified' }
FuzzyGraphDrawer >> highlightOnMouseOver: mainInteraction other: otherInteraction graph1: aGraph graph2: otherGraph [
	| currentGroups |
	currentGroups := RSGroup new.
	"canvas nodes do: [:aNode| |concreteNode| concreteNode := self findEquivalentNode: aNode. concreteNode isFused ifTrue: [aNode @ otherInteraction ] ifFalse: [aNode @ mainInteraction]]."
	canvas nodes
		when: RSMouseEnter do: [ :evt | |concreteNode shape corrShapes perfectMatch|
			shape := evt shape.
				shape class = RSLabel ifFalse: [  "Don't react on highlight the labels"
				concreteNode := self findEquivalentNode: shape.
				corrShapes := self findGroupShape: shape in: aGraph  or: otherGraph.
				perfectMatch := self hasPerfectMatch: concreteNode in: corrShapes.
				perfectMatch ifNil: [ 
					corrShapes add: shape. "Adding the node itself to highlight"
					currentGroups := corrShapes.
					otherInteraction doHighlightShapes: currentGroups.
				] ifNotNil: [ 
					"Remove all from corrshape except perfect"
					corrShapes removeAllSuchThat: [ :elem | elem ~= perfectMatch ]. 
					corrShapes add: shape.
					currentGroups := corrShapes.
					mainInteraction doHighlightShapes: currentGroups.
				].].
			evt signalUpdate.
	].
	canvas
		when: RSMouseMove do: [ :evt | 
			evt shape class = RSLabel ifFalse: [ "Don't react on highlight the labels"
			currentGroups isEmpty ifFalse: [ 
				otherInteraction unhighlightRecordedShapes: currentGroups.
				mainInteraction unhighlightRecordedShapes: currentGroups.
			].].
			evt signalUpdate ].
]

{ #category : #accessing }
FuzzyGraphDrawer >> nodeMap: anObject [
	nodeMap := anObject.
]

{ #category : #drawing }
FuzzyGraphDrawer >> open [
	self g1 ifNil: [ 
		self processFiles. "Load the graphs"
		self colorGraphs. "Calculate the colors"
		self fuseBoth. "Fuse the graphs"
	].
	self drawEverythingOn: canvas hideDead: false.
	canvas open.
]

{ #category : #'processing files' }
FuzzyGraphDrawer >> processFiles [
	|fileV1 fileV2 contentV1 contentV2|
	fileV1 := targetPath , '/' , (filename withoutSuffix: '.COB') , '_V1.gv'.
	fileV2 := targetPath , '/', (filename withoutSuffix: '.COB') , '_V2.gv'.
	contentV1 := (fileV1 asFileReference) contents lines.
	contentV2 := (fileV2 asFileReference) contents lines.
	g1 := FuzzyGraph with: contentV1.
	g2 := FuzzyGraph with: contentV2.
]

{ #category : #removing }
FuzzyGraphDrawer >> removeDeadNodes: aCollection [
	|dead|
	dead := OrderedCollection new.
	aCollection do: [ :each | 
		each linksTo isEmpty ifTrue: [ each isStart ifFalse: [ (dead includes: each) ifFalse: [dead add: each. ] ] ] "If there is no in link, all dead except the start node"
									ifFalse: [ (each linksTo allSatisfy: [ :link | dead includes: link nodeFrom ]) ifTrue: [  dead add: each. ] ]. "If all links in are dead, it's dead"
	].
	^ dead
]

{ #category : #'as yet unclassified' }
FuzzyGraphDrawer >> resertCanvas: aCanvas [
	aCanvas shapes copy do: #remove.
	aCanvas announcer: nil.
	aCanvas signalUpdate.
]

{ #category : #accessing }
FuzzyGraphDrawer >> targetPath: aString [ 
	targetPath := aString 
]
