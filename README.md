# NegotiationApp
Game of Nines for Cognitive Modelling: Complex Behaviour

Things changed over the weeked:
- Made the viewModel less 'powerful' by removing interactions between the cognitive model and the game model that went through the viewModel.
- Replaced all retrievals with partial matching.
- For that, implemented a mismatch function (the code for which is at the end of the InitModel file).
- Reorganisation of parts of the modelResponse() function:
    - deleted some redundant lines
    - made seperate functions for the model's opening bid, as well as a function for when it decides its own strategy (by retreiving a strategy chunk)
    - moved the adding of a new experience to the top of modelResponse(), as some values change while the model is doing its thing
- UI now gives a PSA to tell the player what their MNS is on the start of a new round.
- Implemented more dynamic messaging. Used the lists if accept/reject messages Luka wrote, for the model's accept/reject messages, where the models mood corresponds to its strategy (cooperative=happy, and so on). Also, added a few message templates for 'normal' bid messages, which could use more examples, and maybe even also be split into different moods.
- The lists of messages were pulled out of the viewModel file, and put into a new "Messages" file, which makes the viewModel quite a bit shorter.
- Added an app icon! Subject to change of course. Which is just dragging a 1024x1024 pixel image into the AppIcon thing in the Assets.xcassets file thing.
- Beginnings of user management:
    - Added the three of us as users
    - Whichever user was selected previously get moved to the top of the user name list (and thus the selection as well)
    - Models get saved at the end of every round (so 5 times per 'game')
    - On loading models from json files (JSONManager file), each chunk value has to be reassigned to the new 'model', or else the chunk retrieval causes the whole thing to crash (I think maybe when initialising/loading a new model, the chunks need a key to find the main model)
    - Ability to delete players from the list of names (the corresponding json file also gets deleted), and if all players are deleted, then the view goes back to the main SelectModelScreen, where you can only press "newPlayer".
- The initial value of modelStrategy is now dealt with on init(), where the strategy is decided by whichever strategy chunk it can retrieve. In a sense, it's picking up with the strategy that it left off with.

Tuesday:
- Changed the chunk-retrieval (opening) failure cases to bid for a number from its declared MNS to 9.
- Made the reject button say "quit round" unless the model has made a final offer (and make sure the function it calls it working right, in the case it's "quit round").
- Fixed the bug where the accept/reject offer buttons were always active if you changed which user was playing.
- Moved reinforcement of strategy chunks so that it only reinforces after successfully retrieving the player's strategy


Wednesday:
- Fixed naviagtion links, now can easily go back from any screen (on the first game). Once in new player/ load player goes back to title screen instead of Select Model screen, but I think it is not a big deal.
- The model now accepts the player's offer if it was gonna make the same one (could still check to correct that it accepts if the player makes the same one as the model just did, which should't happen because of the accept button)
- Changed colour and position of removePlayer Button
- Added insist messages for the model and player
- Fixed How To Play options button
- Dan: fixed bug where the round number display wasn't updating on the contentView if the model accepted or rejected.
- Dan: removed possibility for the model to make a "Neutral" strategy chunk when detecting the player's strategy; there should only be Cooperative and Aggressive.
- Dan: fixed bug where the PSA of how many points the player got was incorrect, in cases where the model was accepting the player's offer.
- Dan: refactoring of gameOverView screen by pulling the if conditions out of the view body, its much shorter now

Bugs & Things to work on:
Weekend:
- The retrieval of the opening offer still isn't great, it seems to just generate a random offer fairly often, which sometimes puts the model in a terrible starting place because it asks for just 1 or 2 points. Needs some work to get the retrievals to succeed.

- //(done but maybe needs some adjustments)I fixed a weird thing if you press "Load Session" or "New Player", the background moves slightly, but now its more clear that the "Back" buttons are changing, but I can't work out how to fix this. Perhaps the player selection pages just need to be split up into 3 different views. But I think maybe we ask Luka about this first, because the navigation links are messy.

Tuesday:
- Increase set of messages. 
- The back button on the contentView disappears if you finish a game, then press "new game" on the end-game screen (ask Luka to look at because the back buttons are driving me insane, idk where this one is defined at all).


Wednesday:
- model sometimes bids 0 in opening bid even when it declared higher MNS (I only saw it twice)
- Increase the insist messages (only two now)
- The final offer doesnt really work, the model doesnt retrieve a decision (even though it's suppoused to be enforced)
- Buttons on the gameOverView should be lower I think, they look awkward.
