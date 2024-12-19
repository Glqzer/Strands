# Strands - Functional Programming 

## Project Design Deliverables
* See Project Design PDF
* [Working Libraries Demo](https://livejohnshopkins-my.sharepoint.com/:v:/g/personal/mchoi42_jh_edu/ETfg_QCS2yFCi37OMw1g6RYBx7ji-p8WKJmzipr4PIf1gQ?nav=eyJyZWZlcnJhbEluZm8iOnsicmVmZXJyYWxBcHAiOiJPbmVEcml2ZUZvckJ1c2luZXNzIiwicmVmZXJyYWxBcHBQbGF0Zm9ybSI6IldlYiIsInJlZmVycmFsTW9kZSI6InZpZXciLCJyZWZlcnJhbFZpZXciOiJNeUZpbGVzTGlua0NvcHkifX0&e=hbbMwN).


## Starting the server
```
dune build
dune exec ./_build/default/src/server/server.exe 

```

## Starting Rescript
Run from root

```
cd ./client
yarn
npm run res:build
yarn dev

```

## Code Coverage Commands
```
rm -rf _coverage (* use this if necessary *)
bisect-ppx-report html
```

## CODE CHECKPOINT: What is working, what is not!
### Backend
#### GOOD TO GO PARTS: 
- all letters of spangram are placed on the grid such that, they're IN BOUNDS and NO OVERLAPS.
- There are notions of RANDOMNESS when it comes to:
    - (1) which orientation to use from
    - (2) spangram starting point (at a random col for vertical path, random row for horizontal path),
    - (3) the directions that the spangram letters chooses from 

- We also added to our game.ml and game.mli file which essentially encapsulates our grid and methods for checking solutions. The motivation is that this significantly simplifies our server.ml code by having an instance of game state - **QUESTION: WOULD A MONADIC APPROACH BE MORE APPROPRIATE FOR THIS?**

#### MAIN ISSUE(S): 
- there are still a few chances where the spangram generates orphans :/// i am trying to debug [check_no_orphans] function to see in what cases they don't work. i mentioned this on [COURSELORE #193] . also there is also a limitation on when the spangram is way too long
- (1) Letter placement for words sometimes skips cells and places them in a way where the word isn't continuous
- (2) Letter placement for words (logically) will sometimes have words cross one another path-wise
- (3) Word placement function stops before all possible cells are filled due to a logic issue in algorithm

#### PENDING / Currently working on: 
(1) updating game.ml to tie together overall grid generation with the word found record 
(2) debugging the above issues 
(3) refactor the grid file such that we have a module for Direction with type t;
and we wanna use [@@deriving enumerate] isntead of all_directions list in current Grid module
(4) Working on debugging issues 1, 2, and 3 listed above

- TESTING: made test suites for different modules (Alpha, Coord, Grid) in tests_strands files. 

Right now, Coverage report overall is 94.02% 
**We added a screenshot of our code coverage**

### Frontend and Server
#### GOOD TO GO PARTS: 
- Please see our [screenshots folder](./screenshots/) for a visual of our front-end progress!
- Currently the front-end is "fully functional" in the sense that:
    - Words are able to be selected, cleared, validated
    - The spangram word will be highlighted yellow when submitted and correct
    - Other valid words will be highlighted green when submitted and correct
    - Incorrect words will not be validated
    
- Server - for the images where the full grid is displayed, we are using a sample grid with a hard-coded word coordinate solution. 
    - The server has 2 implementations of the /validate path, one using the hardcoded grid and one using the result of place_spangram. The hardcoded grid is to demonstrate our working "checker" functionality and will (hopefully) be replaced with the complete grid
    - The server initializes the game_state which it then communicates to the frontend. We currently have an /initialize and /validate route:
    - The initialize route responds with game_state.board and the /validate route receives the word and coordinates from the front-end and responds with whether the word is valid or a spangram
    

#### MAIN ISSUE(S):
- Frontend
    - We are currently running into a few edge cases issues with the grid interaction (ex. if you select a letter, deselect it, then select another letter that is far away from it, you are unable to select letters around it)
    - Need to display several conditions such as error messages when the word is invalid and also a message when the user beats the game
    - Would like to make the UI a bit nicer in general

- Server
    - Our primary issue is using the hardcoded sample_grid which is both a server and backend issue. The biggest roadblock is that currently, the functions to place words and spangrams do not create, update, and return a grid that contains the map of word coordinates which is used to verify words. Once this is implemented, the frontend and backend should be fully connected
    - We are doing our best to work around this issue by ensuring that individual libraries are working with the frontend
        - The game state from our Game library seems to be working as intended. We can get the board and spangram from the initialized game_state
        - /initialize and /validate are able to communicate with the front-end


#### TESTING
- I think it would be nice to incorporate some frontend and API testing frameworks - we will look into it

## FINAL SUBMISSION: FIXES 
### Frontend and Server

- Please see our [screenshots folder](./screenshots/final) to see updated images of our front-end! We made many changes such as having a Home Page, three different modes, links to our Github and Slides. We also made the game screen much nicer - added the theme phrase and better UI for the found words as well as error messages and a message for winning the game.

#### ISSUES RESOLVED:
- Frontend
    - At the time of the checkpoint, we ran into a few edge cases issues with the grid interaction. These have all been resolved so only valid tiles can be selected.
    - We included error messages for invalid words as well as a modal for when the user wins the game!
    - UI was organized, added a nicer color palette, added some additional modifications to the front-end and "completeness" of the project by including a Home page, a static, dynamic, and playground mode, as well as links to our Github and slides
    - We refactored our frontend to be much more component-based.
- Server
    - Major updates to the server to allow for static and dynamic board creation as well as the playground mode.
    - Previously, we only had a static, hard-coded grid, but we created new routes that allow for our backend grid-creation functions to generate the front-end board dynamically. We also created new routes to be used by our playground mode which allow the user to enter a theme and a spangram to test the spangram generation.
    - Our game.ml has been updated to properly link together the grid and solution records for a game instance to create a "config"
- Backend 
    - check_no_orphans fully works now where the spangram and all of the other word will NEVER have a configuration where orphan regions will form!
    - the code works best when the the spangram is either 6 or 8 letters long (always generates well), but still it also works for very long spangrams (there are screenshots as proof)
    - we found that the grid can be more and more accurate as more "retries" are given. This helps give the algorithm more opportunitites to backtrack and find alternative paths for each letter, BUT this comes with a TRADE-OFF for how long it takes to run the program. 
    - fp strands dynamic mode NOW can randomly pick from multiple text files and it should generate that particular theme to the front-end, just refresh and it does it automatically! 
    - as you can see, the dyanmic mode is very much playable and the word coordinates are always accurate to the positions on the board <3

