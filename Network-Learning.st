!classDefinition: #EchoConnection category: #'Network-Learning'!
Object subclass: #EchoConnection
	instanceVariableNames: 'socket oldMessage currentMessage'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Network-Learning'!

!EchoConnection methodsFor: 'as yet unclassified' stamp: 'RH 8/31/2021 14:39:18'!
currentMessage
	"Go ahead and get the current message in the socket"
	socket isValid
		ifTrue: [
			|newMessage idx|
			newMessage _ socket receiveAvailableData.
			(newMessage isNil or: [newMessage isEmpty]) ifTrue:[^nil].
			idx _ newMessage indexOf: Character cr.
			idx > 1 ifTrue: [newMessage _ newMessage copyFrom: 1 to: idx - 1].
			oldMessage _ currentMessage.
			currentMessage _ newMessage].
	^currentMessage! !

!EchoConnection methodsFor: 'as yet unclassified' stamp: 'RH 8/31/2021 10:42:34'!
destroy
	socket destroy.
	oldMessage _ nil.
	currentMessage _ nil! !

!EchoConnection methodsFor: 'as yet unclassified' stamp: 'RH 8/31/2021 14:17:47'!
echo
	currentMessage ifNotEmpty: [socket sendData: 'ECHO: ', currentMessage, String crlfString]! !

!EchoConnection methodsFor: 'as yet unclassified' stamp: 'RH 8/31/2021 11:56:02'!
isUnconnected
	^socket isUnconnected! !

!EchoConnection methodsFor: 'as yet unclassified' stamp: 'RH 8/31/2021 11:55:57'!
isValid
	^socket isValid! !

!EchoConnection methodsFor: 'as yet unclassified' stamp: 'RH 8/31/2021 09:16:34'!
oldMessage
	"For debug purposes to see what was the previous echo message"
	^oldMessage! !

!EchoConnection methodsFor: 'as yet unclassified' stamp: 'RH 8/31/2021 11:59:54'!
setSocket: aSocket
	socket _ aSocket.
	oldMessage _ String new.
	currentMessage _ String new! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'EchoConnection class' category: #'Network-Learning'!
EchoConnection class
	instanceVariableNames: ''!

!EchoConnection class methodsFor: 'as yet unclassified' stamp: 'RH 8/31/2021 09:20:59'!
on: aSocket
	^self new setSocket: aSocket! !


!classDefinition: #EchoService category: #'Network-Learning'!
Object subclass: #EchoService
	instanceVariableNames: 'socket port maxConnections connections acceptProcess messageProcess accessSema isRunning'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Network-Learning'!

!EchoService methodsFor: 'as yet unclassified' stamp: 'RH 8/31/2021 14:12:05'!
acceptLoop
	|newConnection|
	
	socket _ Socket newTCP.
	socket listenOn: port backlogSize: maxConnections.
	
	[isRunning] whileTrue: [
		newConnection _ socket waitForAcceptFor: 10 ifTimedOut: [ nil ].
		(newConnection notNil and: [newConnection isConnected]) ifTrue: [
			self addConnection: newConnection.
			newConnection _ nil.
			self changed: self].
		self pruneStaleConnections.
		"Wait a while"
		(Delay forMilliseconds: 100) wait]! !

!EchoService methodsFor: 'as yet unclassified' stamp: 'RH 8/31/2021 14:11:50'!
addConnection: aSocket
	accessSema critical: [
		|echoConn|
		connections size >= maxConnections ifTrue: [Transcript show: 'At max connections.';cr. ^self].
		echoConn _ EchoConnection on: aSocket.
		connections addLast: echoConn.
		Transcript show: 'connection added']! !

!EchoService methodsFor: 'as yet unclassified' stamp: 'RH 8/31/2021 13:38:46'!
destroy
	acceptProcess ifNotNil: [
		acceptProcess terminate.
		acceptProcess _ nil].
	messageProcess ifNotNil: [
		messageProcess terminate.
		messageProcess _ nil].
	socket ifNotNil: [
		socket destroy.
		socket _ nil].
	connections do: [:s | s destroy].
	connections _ OrderedCollection new.! !

!EchoService methodsFor: 'as yet unclassified' stamp: 'RH 8/31/2021 13:40:26'!
isRunning
	accessSema critical: [^isRunning]! !

!EchoService methodsFor: 'as yet unclassified' stamp: 'RH 8/31/2021 13:40:45'!
isRunning: aBoolean
	accessSema critical: [isRunning _ aBoolean]! !

!EchoService methodsFor: 'as yet unclassified' stamp: 'RH 8/31/2021 14:47:04'!
messageLoop
	[isRunning] whileTrue: [
		accessSema critical: [
				connections ifNotEmpty: [
						connections do: [:connection |
								|msg|
								msg _ connection currentMessage.
								msg isEmptyOrNil not
									ifTrue:[
										Transcript show: 'Received: ', msg;cr.
										connection echo]						
							]
					]
			].
			"Wait for a while"
			(Delay forMilliseconds: 100) wait
		]! !

!EchoService methodsFor: 'as yet unclassified' stamp: 'RH 8/31/2021 12:03:26'!
pruneStaleConnections
	accessSema critical: [
		| foundStaleConnection |
		foundStaleConnection _ false.
		connections do: [:s |
			s isUnconnected ifTrue: [
				s destroy.
				foundStaleConnection _ true]].
		foundStaleConnection ifTrue: [
			connections _ connections select: [:s | s isValid]]]! !

!EchoService methodsFor: 'as yet unclassified' stamp: 'RH 8/31/2021 14:46:01'!
setPort: aPort maxConnections: aNumber
	port _ aPort.
	maxConnections _ aNumber.
	accessSema _ Semaphore forMutualExclusion.
	connections _ OrderedCollection new.
	socket _ nil.
	self isRunning: true.
	acceptProcess _ [self acceptLoop] newProcess.
	acceptProcess priority: Processor highIOPriority.
	acceptProcess name: 'EchoService.AcceptSocket'.
	messageProcess _ [self messageLoop] newProcess.
	messageProcess priority: Processor lowIOPriority.
	messageProcess name: 'EchoService.ProcessMessage'! !

!EchoService methodsFor: 'as yet unclassified' stamp: 'RH 8/31/2021 14:46:34'!
start
	self isRunning
	ifFalse: [
		self isRunning: true.
		acceptProcess resume.
		messageProcess resume]! !

!EchoService methodsFor: 'as yet unclassified' stamp: 'RH 8/31/2021 14:42:59'!
stop
	self isRunning
	ifTrue: [
		self isRunning: false.
		acceptProcess suspend.
		messageProcess suspend]
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'EchoService class' category: #'Network-Learning'!
EchoService class
	instanceVariableNames: ''!

!EchoService class methodsFor: 'as yet unclassified' stamp: 'RH 8/31/2021 09:21:38'!
port: aPort maxConnections: aNumber
	^self new setPort: aPort maxConnections: aNumber! !
