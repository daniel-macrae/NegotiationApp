# NegotiationApp
Game of Nines for Cognitive Modelling: Complex Behaviour


Overview:
The NegotiationModel file is very large now, modelResponse() is the main function for the cognitive model. It's become rather complicated, but in short works in three phases (following what the paper does): 1. determining what strategy the player is using by retreiving a chunk with info about what the player just did, 2. determining the model strategy by trying to retrieve one of the two strategy chunks (cooperative, or aggressive) and finally 3. deciding what the model should do. The code for this last part is long, and has a number of 'if' conditions that we use to encourage the model to do the right thing at the right time.
The game itself, with the calculation of scores, round numbers, etc etc, seems to work as it should in all of testing. But keeping an eye out for any bugs is probably good anyway.
The viewModel contains a isPlayerTurn variable that disables the player's offer buttons while the model is responding, or if the animations of the messages is happening.

The number of rounds is temporarily set to 2 ("maxRoundNumber" variable at the top of the model file) because it allows us to get to the end of the game faster, for debugging, but this should be changed back to 5 once we're done with everything.

A very new feature is the model's "typing message". So when the model needs to send a message, a message with just "..." is sent, to show that the model is typing. After some duration (currently set to 2 seconds in the negotiationModel file as the _modelResponseDuration_ variable), the viewModel replaces the ... text in the message with the actual text of the model's bid/decision/whatever else. We might look at letting the model itself decide how long it takes to respond by also learning how long the player is taking.


Model bugs:
- N/A, but we're keeping an eye on how well the retrievals are working.
- Potentially look at the model's timing, especially if we want it to replicate how long the player takes ot make a bid.

UI bugs:
- The back button on the contentView disappears if you finish a game, then press "new game" on the end-game screen. Important note for this one, the navigationLinks that lead to the contentView *must* call the viewModel.resetGame() function for the game to initialise itself properly (especially if the player leaves the contentView and comes back to it, the scores and bids should be reset), not having this causes a lot of headaches...
- Double check to see if the model's typing messages are timed right, and that its not possible for the player to respond while messages are being sent by the model or any PSAs.


Other things for us to adjust or improve:
- Increase set of messages. 
- Buttons on the gameOverView should be lower? I think they look a little awkward. maybe they should be on top of each other as well?
- [should be fixed, but maybe use the lab computer to check this next week] It should not be possible for the player to declare a new MNS before the newRound PSAs happen (it seems to be possible if the player clicks very quickly after accepting/rejecting a bid).
- Change icon colours

