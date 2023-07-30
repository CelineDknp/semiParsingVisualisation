Class {
	#name : #FuzzyGraphNode,
	#superclass : #Object,
	#instVars : [
		'id',
		'text',
		'color',
		'linksFrom',
		'linksTo',
		'isStart',
		'isEnd',
		'matchGroup'
	],
	#category : #CustomParsingVisualisation
}

{ #category : #'instance creation' }
FuzzyGraphNode class >> with: id and: text [ 
	^ self new
	id: id;
	text: text;
	color: #gray;
	isStart: false;
	isEnd: false;
	linksFrom: OrderedCollection new;
	linksTo: OrderedCollection new;
	matchGroup: Set new;
	yourself.
]

{ #category : #'instance creation' }
FuzzyGraphNode class >> with: id and: text matches: anObject [
	^ self new
	id: id;
	text: text;
	color: #gray;
	isStart: false;
	isEnd: false;
	linksFrom: OrderedCollection new;
	linksTo: OrderedCollection new;
	matchGroup: anObject;
	yourself.
]

{ #category : #adding }
FuzzyGraphNode >> addLinkFrom: anObject [
	linksFrom add: anObject.

]

{ #category : #adding }
FuzzyGraphNode >> addLinkTo: anObject [
	linksTo add: anObject.

]

{ #category : #accessing }
FuzzyGraphNode >> color [
	^ color
]

{ #category : #accessing }
FuzzyGraphNode >> color: aColor [
	color := aColor
]

{ #category : #accessing }
FuzzyGraphNode >> detailedLabel [
	self isFused ifTrue: [ 
		|array|
		array := self internalNodes collect: [ :each | each label ].
		^ array joinUsing: '+'.
	 ].
	^ text.
]

{ #category : #accessing }
FuzzyGraphNode >> id [
	^ id
]

{ #category : #accessing }
FuzzyGraphNode >> id: aNumber [
	id := aNumber
]

{ #category : #accessing }
FuzzyGraphNode >> isEnd [
	^isEnd.
]

{ #category : #accessing }
FuzzyGraphNode >> isEnd: aBool [
	isEnd := aBool.
]

{ #category : #testing }
FuzzyGraphNode >> isFused [
	^ false
]

{ #category : #accessing }
FuzzyGraphNode >> isStart [
	^isStart.
]

{ #category : #accessing }
FuzzyGraphNode >> isStart: aBool [
	isStart := aBool.
]

{ #category : #testing }
FuzzyGraphNode >> isStartEnd [
	^ self isStart or: self isEnd.
]

{ #category : #accessing }
FuzzyGraphNode >> label [
	^ text.
]

{ #category : #accessing }
FuzzyGraphNode >> linksFrom [
	^linksFrom
]

{ #category : #accessing }
FuzzyGraphNode >> linksFrom: anObject [
	linksFrom := anObject 
]

{ #category : #accessing }
FuzzyGraphNode >> linksTo [
	^linksTo 
]

{ #category : #accessing }
FuzzyGraphNode >> linksTo: anObject [
	linksTo := anObject 
]

{ #category : #accessing }
FuzzyGraphNode >> matchGroup [
	^ matchGroup.
]

{ #category : #accessing }
FuzzyGraphNode >> matchGroup: anObject [
	matchGroup := anObject.
]

{ #category : #printing }
FuzzyGraphNode >> printOn: aStream [
	<category: 'printing'>
	text printOn: aStream.
   aStream nextPutAll: ' ('.
   id printOn: aStream.
   aStream nextPutAll: ')'.
   "aStream nextPutAll: ' f:'.
   linksFrom printOn: aStream.
   aStream nextPutAll: ' t:'.
   linksTo  printOn: aStream."
]

{ #category : #removing }
FuzzyGraphNode >> removeDup: aList [
	|allCouple remove|
	allCouple := OrderedCollection new.
	remove := OrderedCollection new.
	aList do: [ :link |
		|val |
		val := Array with: link nodeFrom with: link nodeTo.
		(allCouple includes: val) ifTrue: [ 
			remove add: link. "Remove if found already and if not to be removed"
		] ifFalse: [ 
			allCouple add: val.
		].].
		remove do: [ :each | aList remove: each. ].
]

{ #category : #removing }
FuzzyGraphNode >> removeDuplicate [
	self removeDup: linksFrom.
	self removeDup: linksTo.
]

{ #category : #access }
FuzzyGraphNode >> text [
	^ text
]

{ #category : #accessing }
FuzzyGraphNode >> text: aString [
	text := aString
]
