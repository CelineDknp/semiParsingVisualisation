"
Holds the main application to visualize the fuzzy parsed CFGs and their trace equivalence. 
Is composed of a main vertical layout containing the form which is a _CustomFuzzyPresenterForm_. Dispatches infos from the user to the other classes

Instanciate with: `CustomParsingApplication new run.`

Instance Variables
- **form**:	Holds the _CustomFuzzyPresenterForm_ instance

Implementation Points
- `start`: Creates and open the form. Called by run.
"
Class {
	#name : #CustomParsingApplication,
	#superclass : #SpApplication,
	#instVars : [
		'form'
	],
	#category : #CustomParsingVisualisation
}

{ #category : #specs }
CustomParsingApplication class >> defaultSpec [
    ^ SpBoxLayout newVertical
 
     add: #form;
     yourself
]

{ #category : #accessing }
CustomParsingApplication >> start [
    ^ ( self new: CustomFuzzyPresenterForm  ) openWithSpec.
]
