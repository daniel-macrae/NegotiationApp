# NegotiationApp
Game of Nines for Cognitive Modelling: Complex Behaviour

Things changed over the weeked:
- Made the viewModel less 'powerful' by removing interactions between the cognitive model and the game model that went through the viewModel.
- Replaced all retrievals with partial matching.
- For that, implemented a mismatch function (the code for which is at the end of the InitModel file).
- Reogranisation of parts of the modelResponse() function:
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



Bugs & Things to work on:
- The retrieval of the opening offer still isn't great, it seems to just generate a random offer fairly often, which sometimes puts the model in a terrible starting place because it asks for just 1 or 2 points. Needs some work to get the retrievals to succeed.
- Maybe we change the chunk-retrieval failure cases to bid for a number from 9 to its MNS.
- Make the reject button say "quit round" unless the model has made a final offer (and make sure the function it calls it working right, in the case it's "quit round").
- There are cases where the model makes the exact same splitting of 9 points bid as the player (i.e., the player bids "I want 5, you get 4", then the model says "I want 4, you get 5", which is the same thing...). So maybe we should add a condition where if the model makes the same split offer as the player, just accept the player's offer. 
- I fixed a weird thing if you press "Load Session" or "New Player", the background moves slightly, but now its more clear that the "Back" buttons are changing, but I can't work out how to fix this. Perhaps the player selection pages just need to be split up into 3 different views. But I think maybe we ask Luka about this first, because the navigation links are messy.
- I've added a button to remove a user, but for now its just white text under the dropdown menu . It should probably be red text anyway, but I also don't know where to put it exactly. Also, it might be good if a pop-up menu came up after that asking the user if they're sure they want to delete this user.




