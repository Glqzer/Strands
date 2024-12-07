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
- BACKEND GOOD TO GO PARTS: all letters of spangram are placed on the grid such that, they're IN BOUNDS and NO OVERLAPS.
There are notions of RANDOMNESS when it comes to:
 (1) which orientation to use from,
 (2) spangram starting point (at a random col for vertical path, random row for horizontal path), 
 (3) the directions that the spangram letters chooses from

- MAIN ISSUE(S): there are still a few chances where the spangram generates orphans :/// i am trying to debug [check_no_orphans] function to see in what cases they don't work. i mentioned this on [COURSELORE #193] . also there is also a limitation on when the spangram is way too long
- (1) Letter placement for words sometimes skips cells and places them in a way where the word isn't continuous
- (2) Letter placement for words (logically) will sometimes have words cross one another path-wise
- (3) Word placement function stops before all possible cells are filled due to a logic issue in algorithm

- PENDING / Currently working on: 
(1) updating game.ml to tie together overall grid generation with the word found record 
(2) debugging the above issues 
(3) refactor the grid file such that we have a module for Direction with type t;
and we wanna use [@@deriving enumerate] isntead of all_directions list in current Grid module
(4) Working on debugging issues 1, 2, and 3 listed above

- TESTING: made test suites for different modules (Alpha, Coord, Grid) in tests_strands files. 

Right now, Coverage report is 94.16% for src/lib/grid.ml