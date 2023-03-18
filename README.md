# NegotiationApp
Game of Nines for Cognitive Modelling: Complex Behaviour


Things to work on:
- The retrieval of the opening offer still isn't great, it seems to just generate a random offer fairly often, which sometimes puts the model in a terrible starting place because it asks for just 1 or 2 points. Needs some work to get the retrievals to succeed.
- Maybe we change the chunk-retrieval failure cases to bid for a number from 9 to its MNS.
- Make the reject button say "quit round" unless the model has made a final offer (and make sure the function it calls it working right, in the case it's "quit round").
- Put the saving of a new memory at the top of the model response function.
- Maybe break the modelResponse() into more sub-functions? I think the retrieval of an opening big could be its own function, because modelResponse() is not a short function...
- We can make the initialisation of the playerStrategy and modelStrategy (i.e. making the variables at the top of the Model file) be based off of the model's memory by adding an init() function, like in the viewModel. Inside of the init, we can call a function that does something like retrieve the strategy chunk with the highest activation, and then assign the result to the layerStrategy and modelStrategy variables. The idea would be that the model is picking up from the strategy it was probably using the last time it played against this person. 
- There are cases where the model makes the exact same splitting of 9 points bid as the player, so maybe we should add a condition where if the model makes the same split offer as the player, just accept the player's offer. (i.e., the player bids "I want 5, you get 4", then the model says "I want 4, you get 5", which is the same thing...)
- For some reason, if you press "Load Session" or "New Player", the background moves slightly?
- I still need to add that it deletes the JSON file if you delete the player from the list of names
- When all players are deleted, then it goes back to the "SelectModelScreen", which is great, but on this page the back button disappears?


Things changed over the weeked:
- Made the viewModel less 'powerful' by removing interactions between the cognitive model and the game model that went through the viewModel.
- Replaced all retrievals with partial matching.
- For that, implemented a mismatch function (the code for which is at the end of the InitModel file).
- UI now gives a PSA to tell the player what their MNS is on the start of a new round.
- Implemented more dynamic messaging. Used the lists if accept/reject messages Luka wrote, for the model's accept/reject messages, where the models mood corresponds to its strategy (cooperative=happy, and so on). Also, added a few message templates for 'normal' bid messages, which could use more examples, and maybe even also be split into different moods.
- The lists of messages were pulled out of the viewModel file, and put into a new "Messages" file, which makes the viewModel quite a bit shorter.
- Added an app icon! Subject to change of course. Which is just dragging a 1024x1024 pixel image into the AppIcon thing in the Assets.xcassets file thing. Quite easy to just find an image online, crop it, use a website to get it to the right size (it has to be exact) and drag it onto the box. Doesn't always seem to show on the simulator though...
- Beginnings of user management:
    - Added the three of us as users
    - Whichever user was selected previously get moved to the top of the user name list (and thus the selection as well)
    - Models get saved at the end of every round (so 5 times per 'game')
    - On loading models from json files (JSONManager file), each chunk value has to be reassigned to the new 'model', or else the chunk retrieval causes the whole thing to crash (I think maybe when initialising/loading a new model, the chunks need a key to find the main model)
    - Ability to delete players from the list of names, and if all players are deleted, then the view goes back to the main SelectModelScreen, where you can only press "newPlayer"

