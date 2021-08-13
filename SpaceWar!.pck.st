'From Cuis 5.0 [latest update: #4687] on 13 August 2021 at 2:50:20 pm'!
'Description '!
!provides: 'SpaceWar!!' 1 1!
SystemOrganization addCategory: 'Spacewar!!'!


!classDefinition: #Mobile category: 'Spacewar!!'!
Morph subclass: #Mobile
	instanceVariableNames: 'velocity acceleration'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Spacewar!!'!
!classDefinition: 'Mobile class' category: 'Spacewar!!'!
Mobile class
	instanceVariableNames: ''!

!classDefinition: #CentralStar category: 'Spacewar!!'!
Mobile subclass: #CentralStar
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Spacewar!!'!
!classDefinition: 'CentralStar class' category: 'Spacewar!!'!
CentralStar class
	instanceVariableNames: ''!

!classDefinition: #SpaceShip category: 'Spacewar!!'!
Mobile subclass: #SpaceShip
	instanceVariableNames: 'name position heading torpedoes fuel'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Spacewar!!'!
!classDefinition: 'SpaceShip class' category: 'Spacewar!!'!
SpaceShip class
	instanceVariableNames: ''!

!classDefinition: #Torpedo category: 'Spacewar!!'!
Mobile subclass: #Torpedo
	instanceVariableNames: 'lifeSpan'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Spacewar!!'!
!classDefinition: 'Torpedo class' category: 'Spacewar!!'!
Torpedo class
	instanceVariableNames: ''!

!classDefinition: #SpaceWar category: 'Spacewar!!'!
Morph subclass: #SpaceWar
	instanceVariableNames: 'centralStar ships torpedoes color'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Spacewar!!'!
!classDefinition: 'SpaceWar class' category: 'Spacewar!!'!
SpaceWar class
	instanceVariableNames: ''!


!Mobile methodsFor: 'as yet unclassified' stamp: 'RPH 8/13/2021 14:27:25'!
gravity
	"Compute the gravity acceleration vector"
	| position |
	position := self morphPosition.
	^-10 * self mass * owner starMass / (position r raisedTo: 3) * position! !

!Mobile methodsFor: 'as yet unclassified' stamp: 'RPH 8/13/2021 14:31:15'!
isGoingOuterSpace
	"Is the mobile going crazy in the direction of the outer space?"
	^(self morphPosition dotProduct: velocity) > 0! !

!Mobile methodsFor: 'as yet unclassified' stamp: 'RPH 8/13/2021 14:30:36'!
isInOuterSpace
	"Is the mobile located in the outer space (outside of the game play area)"
	^(owner morphContainsPoint: self morphPosition) not! !

!Mobile methodsFor: 'as yet unclassified' stamp: 'RPH 8/13/2021 14:14:26'!
mass
	^1! !

!Mobile methodsFor: 'initialization' stamp: 'RPH 8/13/2021 14:40:21'!
initialize
	super initialize.
	super color: Color gray.
	velocity := 0 @ 0.
	acceleration := 0! !

!Mobile methodsFor: 'events-old protocol' stamp: 'RPH 8/13/2021 14:34:13'!
update: t
	"Update the mobile position and velocity"
	| ai ag newVelocity |
	
	"acceleration vectors"
	ai := acceleration * self direction.
	ag := self gravity.
	newVelocity := (ai + ag) * t + velocity.
	self morphPosition:
		(0.5 * (ai + ag) * t squared)
		+ (velocity * t)
		+ self morphPosition.
	velocity := newVelocity.
	
	"Are we out of screen? If so we move the mobile to the other corner and slow it down by a factor of 2"
	(self isInOuterSpace and: [self isGoingOuterSpace]) ifTrue: [
		velocity := velocity / 2.
		self morphPosition: self morphPosition negated]! !

!CentralStar methodsFor: 'initialization' stamp: 'RPH 8/13/2021 14:29:09'!
initialize
	super initialize.! !

!SpaceShip methodsFor: 'initialization' stamp: 'RPH 8/13/2021 14:41:34'!
initialize
	super initialize.
	self resupply! !

!SpaceShip methodsFor: 'accessing - properties' stamp: 'RPH 8/13/2021 13:53:46'!
name: aName
	aName isEmptyOrNil
		ifTrue: [self error: 'name must be set to a non-empty string']
		ifFalse: [name := aName]	! !

!SpaceShip methodsFor: 'as yet unclassified' stamp: 'RPH 8/13/2021 14:04:29'!
fireTorpedo
	"Fire a torpedo in the direction of the ship heading with its velocity"
	| torpedo color location |
	torpedoes isZero ifTrue: [^self].
	torpedoes := torpedoes - 1.
	torpedo := Torpedo new.
	torpedo
		morphPosition: self morphPosition + self nose;
		rotation: location radians;
		velocity: velocity;
		color: color muchLighter.
owner addTorpedo: torpedo! !

!SpaceShip methodsFor: 'as yet unclassified' stamp: 'RPH 8/13/2021 13:56:58'!
left
	"Rotate ship to its left"
	self rotateBy: -0.1! !

!SpaceShip methodsFor: 'as yet unclassified' stamp: 'RPH 8/13/2021 13:55:36'!
push
	"Init an acceleration boost"
	fuel isZero ifTrue: [^self].
	fuel = fuel - 1.
	acceleration := 50! !

!SpaceShip methodsFor: 'as yet unclassified' stamp: 'RPH 8/13/2021 14:41:57'!
resupply
	fuel := 500.
	torpedoes := 20! !

!SpaceShip methodsFor: 'as yet unclassified' stamp: 'RPH 8/13/2021 13:57:23'!
right
	"Rotate ship to its right"
	self rotateBy: 0.1! !

!SpaceShip methodsFor: 'as yet unclassified' stamp: 'RPH 8/13/2021 13:56:06'!
unpush
	"Stop the acceleration boost"
	acceleration := 50! !

!Torpedo methodsFor: 'as yet unclassified' stamp: 'RPH 8/13/2021 14:42:33'!
initialize
	super initialize.
	lifeSpan := 500.
	acceleration := 4000.! !

!Torpedo methodsFor: 'as yet unclassified' stamp: 'RPH 8/13/2021 14:37:15'!
update: t
	"Update torpedo position"
	super update: t.
	"orientate the torpedo in its velocity direction, nicer effect while inaccurate"
	self rotation: (velocity y arcTan: velocity x) + Float halfPi.
	lifeSpan := lifeSpan - 1.
	lifeSpan isZero ifTrue: [owner destroyTorpedo: self].
	acceleration > 0 ifTrue: [acceleration := acceleration - 1000]! !

!SpaceWar methodsFor: 'as yet unclassified' stamp: 'RPH 8/13/2021 10:23:35'!
collisionsShipsStar
	ships do: [:aShip |
		(aShip morphPosition dist: centralStar morphPosition) < 20
			ifTrue: [aShip flashWith: Color red. self teleport: aShip]
			]! !

!SpaceWar methodsFor: 'as yet unclassified' stamp: 'RPH 8/13/2021 11:22:13'!
collisionsShipsTorpedoes
	ships do: [:aShip |
		torpedoes do: [:aTorpedo |
			(aShip morphPosition dist: aTorpedo morphPosition) < 15
				ifTrue: [
					aShip flashWith: Color red.
					aTorpedo flashWith: Color orange.
					self destroyTorpedo: aTorpedo.
					self teleport: aShip]
				]
			]
		! !

!SpaceWar methodsFor: 'as yet unclassified' stamp: 'RPH 8/13/2021 14:09:39'!
initializeActors
	centralStar := CentralStar new.
	self addMorph: centralStar.
	centralStar morphPosition: 0 @ 0.
	ships := Array
		with: (SpaceShip new color: Color white)
		with: (SpaceShip new color: Color red).
	self addAllMorphs: ships.
	ships first morphPosition: 200 @ -200.
	ships second morphPosition: -200 @ 200.
	torpedoes := OrderedCollection new
		! !

!SpaceWar methodsFor: 'as yet unclassified' stamp: 'RPH 8/13/2021 11:06:34'!
teleport: aShip
"Teleport a ship at a random location"
| area randomCoordinate |

aShip resupply.

area := self morphLocalBounds insetBy: 20.
randomCoordinate := [(area left to: area right) atRandom].
aShip
	velocity: 0 @ 0;
	morphPosition: randomCoordinate value @ randomCoordinate value.
! !

!SpaceWar methodsFor: 'initialization' stamp: 'RPH 8/13/2021 11:14:24'!
initialize
"We want to capture keyboard and mouse events, starting the game loop (step) and initialize the actors."
	super initialize.
	color := self defaultColor.
	self setProperty: #'handlesKeyboard' toValue: true.
	self setProperty: #'handlesMouseOver' toValue: true.
	self startSteppingTime: self stepTime.
	self initializeActors! !

!SpaceWar methodsFor: 'stepping' stamp: 'RPH 8/13/2021 10:21:24'!
stepAt: millisecondSinceLast
	ships do: [:each | each unpush].! !

!SpaceWar methodsFor: 'events' stamp: 'RPH 8/13/2021 10:37:16'!
keyStroke: event
"Check for any keyboard stroke, and take action accordingly."
| key |

key := event KeyCharacter.

key = Character arrowUp ifTrue: [^ships first push].
key = Character arrowRight ifTrue:[^ships first first].
key = Character arrowLeft ifTrue:[^ships first left].
key = Character arrowDown ifTrue:[^ships first fireTorpedo]! !

!SpaceWar methodsFor: 'testing' stamp: 'RPH 8/13/2021 10:12:18'!
stepTime
	^20! !
