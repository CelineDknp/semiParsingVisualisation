Class {
	#name : #FuzzyGraphLink,
	#superclass : #Object,
	#instVars : [
		'nodeFrom',
		'nodeTo',
		'label',
		'color'
	],
	#category : #CustomParsingVisualisation
}

{ #category : #'instance creation' }
FuzzyGraphLink class >> with: aString from: aNode to: anotherNode [
	^ self new
	label: aString;
	nodeFrom: aNode;
	nodeTo: anotherNode;
	yourself.
]

{ #category : #comparing }
FuzzyGraphLink >> = another [
	|bool|
	bool := ((self nodeTo = another nodeTo) and:((self nodeFrom = another nodeFrom) and: (self label = another label))).
	^ bool.
]

{ #category : #'instance creation' }
FuzzyGraphLink >> from [
	^nodeFrom.
]

{ #category : #accessing }
FuzzyGraphLink >> label [
	^ label
]

{ #category : #accessing }
FuzzyGraphLink >> label: aString [
	label := aString
]

{ #category : #accessing }
FuzzyGraphLink >> nodeFrom [
	^nodeFrom. 
]

{ #category : #accessing }
FuzzyGraphLink >> nodeFrom: anObject [
	nodeFrom := anObject 
]

{ #category : #accessing }
FuzzyGraphLink >> nodeTo [
	^ nodeTo 
]

{ #category : #accessing }
FuzzyGraphLink >> nodeTo: anObject [
	nodeTo := anObject 
]

{ #category : #printing }
FuzzyGraphLink >> printOn: aStream [
	<category: 'printing'>
	nodeFrom id printOn: aStream.
   aStream nextPutAll: ' -> '.
   nodeTo id printOn: aStream.
   aStream nextPutAll: ' ('.
   label printOn: aStream.
   aStream nextPutAll: ')'.
]

{ #category : #'instance creation' }
FuzzyGraphLink >> to [
	^ nodeTo 
]
