Class {
	#name : #CustomLineListPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'canvas',
		'label'
	],
	#category : #CustomParsingVisualisation
}

{ #category : #specs }
CustomLineListPresenter class >> defaultSpec [

	^ SpPanedLayout newLeftToRight
		  positionOfSlider: 15 percent;
		  add: #canvas;
		  add: #label;
		  yourself
]

{ #category : #accessing }
CustomLineListPresenter >> canvas [
	^ canvas
]

{ #category : #accessing }
CustomLineListPresenter >> canvas: anObject [
	canvas := anObject.
]

{ #category : #accessing }
CustomLineListPresenter >> initializePresenters: c label: l [
	canvas := SpMorphPresenter new
		morph: c canvas createMorph;
		yourself.

	label := SpLabelPresenter new
		label: l;
		yourself.
]

{ #category : #accessing }
CustomLineListPresenter >> label [
	^ label
]

{ #category : #accessing }
CustomLineListPresenter >> label: anObject [
	label := label
]
