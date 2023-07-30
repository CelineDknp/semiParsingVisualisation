"
Represents the form that is the main window of the visualization application.
Asks the user to fill in where are the original COBOL files (both versions) as well as the output of our fuzzy parsing + trace equivalence.
Shows all found files in a list, and allows the user to click on the files to see their graphical visualisation (creates _FuzzyGraphDrawer_)

Instanciate with: `CustomFuzzyPresenterForm new openWithSpec.`

Instance Variables
- **cobolFileInput**: Input allowing the user to specify the path to the COBOL files
- **cobolFileLabel**:	Label accompanying above input
- **outputFileInput**: Input allowing the user to specify the path to the trace equivalenced files
- **outputFileLabel**: Label accompanying above input
- **fileList**: List of files found in the directory **cobolFileInput**. Starts empty and updates every time the user clicks on **visualizeButton**
- **stopButton**: Button to close the window
- **visualizeButton**: Button to load the file list and allow to start visualizing

Implementation Points
- `connectPresenters`: Links the **visualizeButton** to the **fileList** (populate on click) and the **fileList** elements to their opening of _FuzzyGraphDrawer_
- `initializePresenters`: Initialize all the instance variables
- `initializeWindow`: Initialize details about the window: its size and its title
"
Class {
	#name : #CustomFuzzyPresenterForm,
	#superclass : #SpPresenter,
	#instVars : [
		'cobolFileLabel',
		'cobolFileInput',
		'outputFileLabel',
		'outputFileInput',
		'visualizeButton',
		'stopButton',
		'fileList'
	],
	#category : #CustomParsingVisualisation
}

{ #category : #specs }
CustomFuzzyPresenterForm class >> defaultSpec [
   ^ SpPanedLayout newHorizontal 
		add: (SpBoxLayout newVertical
			add: #cobolFileLabel;
   			add: #outputFileLabel;
			addLast: (SpBoxLayout newHorizontal  
  				add: #visualizeButton ;
  				add: #stopButton ; yourself);
			yourself);
		add: (SpBoxLayout newVertical
						add: 'Files' withConstraints: [ :constraints | constraints height: self labelHeight ];
						add: #fileList;
						yourself);
		yourself 
]

{ #category : #initialization }
CustomFuzzyPresenterForm >> connectPresenters [
   visualizeButton action: [ 
      |inputPath outputPath list itemsList|
      inputPath := cobolFileInput text.
      outputPath := outputFileInput text.
		list := inputPath asFileReference,'/V1' allChildrenMatching: '*.COB'.
		itemsList := OrderedCollection new.
		list do:[:each| |p|
			 p := CustomLineListPresenter new.
			 p initializePresenters: (self drawPercent: each basename) label: each basename.
			 itemsList add: p].
		fileList presenters: itemsList.
		"fileList items: itemsList asOrderedCollection sort.
		fileList itemFilter: [ :item :string | item asString includesSubstring: string ];
		displayIcon: [ :elem | self drawPercent: elem ]."
		fileList "enableSearch
			initializeTSearchable;"
			whenSelectionChangedDo: [ 
				:selection | 
					|window|
						window := FuzzyGraphDrawer with: (selection selectedItem label label) and: outputPath. "label label access the label of the custompresenter and then the label inside"
						window open.
						
			].
].
]

{ #category : #'as yet unclassified' }
CustomFuzzyPresenterForm >> createShape: red green: green orange: orange grey: grey [
	|shape b1 b2 b3 b4 view|
	view := RSCanvas new.
	view color: #black.
	shape := RSGroup new.
	((((red = 0) and: (green = 0)) and: (orange = 0)) and: grey = 0) ifTrue: [ 
		b1 := RSBox new color: #gray; height: 18; width: 70.
		shape add: b1.
	 ] ifFalse: [ 
		b1 := RSBox new color: #green; height: 40; width: green.
		b2 := RSBox new color: #red; height: 40; width: red.
		b3 := RSBox new color: #orange; height: 40; width: orange.
		b4 := RSBox new color: #gray; height: 40; width: grey.
		shape add: b1. shape add: b2. shape add: b3. shape add: b4.
		RSHorizontalLineLayout new gapSize: 0; on: shape.
		shape translateBy: -35 @ -10.
	].
	view add: shape asShape.
	^ view 
]

{ #category : #accessing }
CustomFuzzyPresenterForm >> drawPercent: anItem [
	|dict tot green red orange gray|
		dict := self linkDict: anItem.
		tot := 0.
		dict valuesDo: [ :each | tot := tot+each ].
		green := 0. red := 0. orange := 0. gray := 0.
		dict associationsDo: [ :pair | 
			pair key = -1 ifTrue: [ red := ((pair value/tot)*69) ceiling.].
			pair key = 1 ifTrue: [ green := ((pair value/tot)*69) ceiling.].
			pair key = 0 ifTrue: [ orange := ((pair value/tot)*69)ceiling.].
			pair key = -2 ifTrue: [ gray := ((pair value/tot)*69)ceiling.].
		].
		(red > 0 and: (red < 1)) ifTrue: [ red := 1 ].
		(green > 0 and: (green < 1)) ifTrue: [ green := 1 ].
		(orange > 0 and: (orange < 1)) ifTrue: [ orange := 1 ].
		(gray > 0 and: (gray < 1)) ifTrue: [ gray := 1 ].
		
		^ self createShape: red green: green orange: orange grey: gray.
	
]

{ #category : #initialization }
CustomFuzzyPresenterForm >> initializePresenters [
	cobolFileInput := self newTextInput placeholder: 'Path to COBOL files directory'.
	cobolFileLabel := self instantiate: (SpLabeledPresenter label: 'COBOL files' input: cobolFileInput description: 'Directory containing both versions of the COBOL files').
	outputFileInput := self newTextInput placeholder: 'Path to trace equivalence files directory'.
	outputFileLabel := self instantiate: (SpLabeledPresenter label: 'Output files' input: outputFileInput description: 'Directory that will contain the compared files').
	visualizeButton  := self newButton label: 'Visualize' ; yourself. 
	stopButton := self newButton label: 'Stop'; yourself.
	fileList := SpComponentListPresenter new. "Component means no filtering no sorting"
	"fileList headerTitle: 'Found COBOL files'."
	"fileList items: OrderedCollection new."
]

{ #category : #initialization }
CustomFuzzyPresenterForm >> initializeWindow: aWindowPresenter [
	aWindowPresenter 
		title: 'Fuzzy Parsing visualisation';
		initialExtent: 1000 @ 650
]

{ #category : #'as yet unclassified' }
CustomFuzzyPresenterForm >> linkDict: anItem [
	|fileV1 fileV2 contentV1 contentV2 g1 g2 dict1 dict2 dict3|
	fileV1 := outputFileInput text, '/' , (anItem withoutSuffix: '.COB') , '_V1.gv'.
	fileV2 := outputFileInput text, '/', (anItem withoutSuffix: '.COB') , '_V2.gv'.
	[
		contentV1 := (fileV1 asFileReference) contents lines.
		contentV2 := (fileV2 asFileReference) contents lines.
		g1 := FuzzyGraph with: contentV1.
		g2 := FuzzyGraph with: contentV2.
		dict1 := g1 countLinks.
		dict2 := g2 countLinks.
		dict3 := Dictionary new.
		dict1 keysDo: [ :each | dict3 at: each update: [ :value | value + dict1 at: each. ] initial: [ dict1 at: each ].].
		dict2 keysDo: [ :each | dict3 at: each update: [ :value | value + dict2 at: each. ] initial: [ dict2 at: each ].].
		^ dict3 
	] on: FileDoesNotExistException do: [ ^ Dictionary new. ]
]
