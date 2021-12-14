'From Cuis 5.0 [latest update: #4975] on 14 December 2021 at 3:53:13 pm'!
'Description '!
!provides: 'Spacewar!!' 1 0!
SystemOrganization addCategory: 'Spacewar!!'!


!classDefinition: #Mobile category: 'Spacewar!!'!
MovableMorph subclass: #Mobile
	instanceVariableNames: 'acceleration color velocity'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Spacewar!!'!
!classDefinition: 'Mobile class' category: 'Spacewar!!'!
Mobile class
	instanceVariableNames: ''!

!classDefinition: #SpaceShip category: 'Spacewar!!'!
Mobile subclass: #SpaceShip
	instanceVariableNames: 'name position heading fuel torpedoes mass'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Spacewar!!'!
!classDefinition: 'SpaceShip class' category: 'Spacewar!!'!
SpaceShip class
	instanceVariableNames: ''!

!classDefinition: #Torpedo category: 'Spacewar!!'!
Mobile subclass: #Torpedo
	instanceVariableNames: 'position heading lifeSpan'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Spacewar!!'!
!classDefinition: 'Torpedo class' category: 'Spacewar!!'!
Torpedo class
	instanceVariableNames: ''!

!classDefinition: #CentralStar category: 'Spacewar!!'!
Morph subclass: #CentralStar
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Spacewar!!'!
!classDefinition: 'CentralStar class' category: 'Spacewar!!'!
CentralStar class
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


!Mobile methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 14:46:54'!
drawOn: aCanvas polygon: vertices
	| size |
	size _ vertices size.
	vertices withIndexDo: [:aPoint :i |
		aCanvas 
			line: aPoint
			to: (vertices at: (i \\ size + 1))
			width: 2
			color: color]! !

!Mobile methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 10:37:49'!
gravity
	"Compute the gravity acceleration vector"
	| position |
	position _ self morphPosition.
	^ -10 * self mass * owner starMass / (position r raisedTo: 3) * position! !

!Mobile methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 10:50:31'!
initialize
	super initialize.
	color _ Color gray.
	velocity _ 0 @ 0.
	acceleration _ 0! !

!Mobile methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 10:46:31'!
isGoingOuterSpace
	"Is the mobile going crazy in the direction of the outher spacE?"
	^ (self morphPosition dotProduct: velocity) > 0! !

!Mobile methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 10:45:54'!
isInOuterSpace
	"Is the mobile located in the outer space? (outside of the game
	play area)"
	^ (owner morphLocalBounds containsPoint: self morphPosition) not! !

!Mobile methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 10:36:23'!
mass
	^1! !

!Mobile methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 15:04:17'!
morphLocalBounds
	^ Rectangle encompassing: self vertices.! !

!Mobile methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 14:20:32'!
requiresVectorCanvas
	^false! !

!Mobile methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 10:43:02'!
update: t
	"Update the mobile position and velocity"
	| ai ag newVelocity |
	"acceleration vectors"
	ai _ acceleration * self direction.
	ag _ self gravity.
	newVelocity _ (ai + ag) * t + velocity.
	self morphPosition:
		(0.5 * (ai + ag) * t squared)
		+ (velocity * t)
		+ self morphPosition.
	velocity _ newVelocity.
	"Are we out of the screen? If so we move the mobile to the other corner
	and slow it down by a factor of 2"
	(self isInOuterSpace and: [self isGoingOuterSpace]) ifTrue: [
		velocity _ velocity / 2.
		self morphPosition: self morphPosition negated]! !

!Mobile methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 15:03:35'!
vertices
	"vertices to draw polygon"
	self subclassResponsibility! !

!SpaceShip methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 10:32:51'!
direction
	"I am a unit vector reprsenting the nose direction of the mobile"
	^ Point rho: 1 theta: location radians - Float halfPi.! !

!SpaceShip methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 15:40:11'!
fireTorpedo
	"Fire a torpedo in the direction of
	the ship heading with its velocity"
	| torpedo |
	torpedoes isZero ifTrue: [^self].
	torpedoes _ torpedoes - 1.
	torpedo _ Torpedo new.
	torpedo 
		morphPosition: self morphPosition + self nose;
		rotation: location radians. "copy the rotation angel from ship"
	owner addTorpedo: torpedo! !

!SpaceShip methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 10:33:08'!
gravity
	"Compute the gravity acceleration vector"
	position _ self morphPosition.
	^ [ -10 * self mass * owner starMass / (position r raisedTo: 3) * position]
	on: Error do: [0 @ 0]
! !

!SpaceShip methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 08:28:24'!
mass
	^1! !

!SpaceShip methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 15:40:11'!
nose
	^ self direction * 40! !

!SpaceShip methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 09:23:56'!
push
	"init an acceleration boost"
	fuel isZero ifTrue: [^self].
	fuel _ fuel - 1.
	acceleration _ 50! !

!SpaceShip methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 10:51:36'!
resupply
	fuel _ 500.
	torpedoes _ 20! !

!SpaceShip methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 15:42:20'!
teleport: aShip
	"Teleport a ship at a random location"
	| area randomCoordinate |
	aShip resupply.
	area _ self morphLocalBounds insetBy: 20.
	randomCoordinate _ [(area left to: area right) atRandom].
	aShip
		velocity: 0 @ 0;
		morphPosition: randomCoordinate value @ randomCoordinate value! !

!SpaceShip methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 15:36:52'!
turnLeft
	"Rotate the ship to its left"
	self rotateBy: -0.1! !

!SpaceShip methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 15:36:10'!
turnRight
	"Rotate the ship to its right"
	self rotateBy: 0.1! !

!SpaceShip methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 09:24:14'!
unpush
	"Stop the acceleration boost"
	acceleration _ 0! !

!SpaceShip methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 15:42:52'!
velocity: aVector
	velocity _ aVector! !

!SpaceShip methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 14:39:10'!
vertices
	^ `{0@-15 . -10@15 . 0@10 . 10@15}`! !

!SpaceShip methodsFor: 'initialization' stamp: 'RH 12/14/2021 14:29:07'!
initialize
	super initialize.
	vertices _ {0@15 . -10@15 . 0@10 . 10@15}.
	self resupply.! !

!SpaceShip methodsFor: 'accessing - properties' stamp: 'RH 12/14/2021 08:28:16'!
name: aString
	name _ aString! !

!SpaceShip methodsFor: 'updating' stamp: 'RH 12/14/2021 08:42:28'!
update: t
	"Update the ship position and velocity"
	|ai ag newVelocity|
	ai _ acceleration * self direction.
	ag _ self gravity.
	newVelocity _ (ai + ag) * t + velocity.
	position _ (0.5 * (ai + ag) *t squared) + (velocity * t) + position.
	velocity _ newVelocity.! !

!SpaceShip methodsFor: 'drawing' stamp: 'RH 12/14/2021 14:39:35'!
drawOn: aCanvas
	| vertices |
	vertices _ self vertices.
	self drawOn: aCanvas polygon: vertices.
	"Draw gas exhaust"
	acceleration ifNotZero: [
		aCanvas line: vertices third to: 0 @ 35 width: 1 color: Color gray]! !

!SpaceShip methodsFor: 'geometry' stamp: 'RH 12/14/2021 14:24:51'!
morphExtent
	^ `20 @ 30`! !

!Torpedo methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 14:40:23'!
drawOn: aCanvas
	self drawOn: aCanvas polygon: self vertices! !

!Torpedo methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 14:29:38'!
initialize
	super initialize.
	vertices _ {0@-4 . -2@4 . 2@4}.
	lifeSpan _ 500.
	acceleration _ 4000! !

!Torpedo methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 08:26:37'!
mass
	^1! !

!Torpedo methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 10:50:04'!
update: t
	"Update the torpedo position"
	super update: t.
	"orientate the torpedo in its velocity direction, nicer effect
	while inaccurate"
	self rotation: (velocity y arcTan: velocity x) + Float halfPi.
	lifeSpan _ lifeSpan - 1.
	lifeSpan isZero ifTrue: [owner destroyTorpedo: self].
	acceleration > 0 ifTrue: [acceleration _ acceleration - 1000]! !

!Torpedo methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 14:40:15'!
vertices
	^ `{0@-4 . -2@4 . 2@4}`! !

!CentralStar methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 14:22:32'!
drawOn: aCanvas
	| radius |
	radius _ self morphExtent // 2.
	aCanvas 
		ellipseCenterX: 0
		y: 0
		rx: radius x + (2 atRandom - 1)
		ry: radius y + (2 atRandom - 1)
		borderWidth: 3
		borderColor: Color orange
		fillColor: Color yellow ! !

!CentralStar methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 14:21:05'!
morphExtent
	^ `30 @ 30`! !

!CentralStar methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 10:45:06'!
morphLocalBounds
	^ Rectangle center: 0 @ 0 extent: self morphExtent! !

!CentralStar methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 14:20:45'!
requiresVectorCanvas
	^false! !

!SpaceWar methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 15:40:59'!
addTorpedo: aTorpedo
	torpedoes add: aTorpedo.
	self addMorph: aTorpedo! !

!SpaceWar methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 15:51:15'!
defaultColor
	^ `Color black`! !

!SpaceWar methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 15:42:01'!
destroyTorpedo: aTorpedo
	aTorpedo delete.
	torpedoes remove: aTorpedo! !

!SpaceWar methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 15:48:40'!
handlesKeyBoard
	^true! !

!SpaceWar methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 15:48:52'!
handlesMouseOver
	^true! !

!SpaceWar methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 10:35:20'!
initializeActors
	centralStar _ CentralStar new.
	self addMorph: centralStar.
	centralStar morphPosition: 0 @ 0.
	torpedoes _ OrderedCollection new.
	ships _ Array with: SpaceShip new with: SpaceShip new.
	self addAllMorphs: ships.
	ships first
		position: 200 @ -200;
		color: Color green.
	ships second
		position: -200 @ 200;
		color: Color red.! !

!SpaceWar methodsFor: 'as yet unclassified' stamp: 'RH 12/14/2021 10:44:31'!
morphLocalBounds
	^ -500 @ -500 extent: 1000 @ 1000! !

!SpaceWar methodsFor: 'initialization' stamp: 'RH 12/14/2021 09:22:55'!
initialize
	"We want to capture keyboard and mouse events,
	start the game loop(step) and initialize the actors."
	super initialize.
	color _ self defaultColor.
	self setProperty: #'handlesKeyboard' toValue: true.
	self setProperty: #'handlesMouseOver' toValue: true.
	self startSteppingStepTime: self stepTime.
	self initializeActors.! !

!SpaceWar methodsFor: 'events' stamp: 'RH 12/14/2021 15:37:31'!
keyStroke: event
	| key |
	key _ event keyCharacter.
	key = Character arrowUp ifTrue: [^ships first push].
	key = Character arrowRight ifTrue: [^ships first turnRight].
	key = Character arrowLeft ifTrue: [^ships first turnLeft].
	key = Character arrowDown ifTrue: [^ships first fireTorpedo].
	key = $w ifTrue: [^ships second push].
	key = $d ifTrue: [^ships second turnRight].
	key = $a ifTrue: [^ships second turnLeft].
	key = $s ifTrue: [^ships second fireTorpedo]! !

!SpaceWar methodsFor: 'focus handling' stamp: 'RH 12/14/2021 15:30:59'!
keyboardFocusChange: gotFocus
	gotFocus
		ifTrue: [color _ self defaultColor]
		ifFalse: [color _ self defaultColor alpha: 0.5].
	self redrawNeeded! !

!SpaceWar methodsFor: 'geometry testing' stamp: 'RH 12/14/2021 14:20:39'!
requiresVectorCanvas
	^false! !

!SpaceWar methodsFor: 'stepping' stamp: 'RH 12/14/2021 08:47:36'!
stepAt: millisecondSinceLast
	ships do: [:each | each unpush].! !

!SpaceWar methodsFor: 'stepping' stamp: 'RH 12/14/2021 08:46:53'!
stepTime
	"millisecond"
	^20! !

!SpaceWar methodsFor: 'collisions' stamp: 'RH 12/14/2021 15:46:47'!
collisions
	self collisionsShipsStar.
	self collisionsTorpedoesStar.
	self collisionsShipsTorpedoes.
	self collisionsShips! !

!SpaceWar methodsFor: 'collisions' stamp: 'RH 12/14/2021 15:48:23'!
collisionsShips
	(ships first displayBounds intersects: ships second displayBounds)
		ifTrue: [
			ships do: [:aShip | 
				aShip flashWith: Color red.
				self teleport: aShip]]! !

!SpaceWar methodsFor: 'collisions' stamp: 'RH 12/14/2021 14:44:11'!
collisionsShipsStar
	ships do: [:aShip |
		(aShip displayBounds intersects: centralStar displayBounds) < 20 ifTrue: [
			aShip flashWith: Color red.
			self teleport: aShip]]! !

!SpaceWar methodsFor: 'collisions' stamp: 'RH 12/14/2021 10:22:19'!
collisionsShipsTorpedoes
	ships do: [:aShip | 
		torpedoes do: [:aTorpedo |
			(aShip morphPosition dist: aTorpedo morphPosition) < 15 ifTrue: [
				aShip flashWith: Color red.
				aTorpedo flashWith: Color orange.
				self destroyTorpedo: aTorpedo.
				self teleport: aShip]
			]
		]! !

!SpaceWar methodsFor: 'collisions' stamp: 'RH 12/14/2021 15:46:04'!
collisionsTorpedoesStar
	torpedoes do: [:aTorpedo |
		(aTorpedo displayBounds intersects: centralStar displayBounds) ifTrue: [
			aTorpedo flashWith: Color orange.
			self destroyTorpedo: aTorpedo]]! !
