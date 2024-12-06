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

## CODE CHECKPOINT: What is working, what is not!
- BACKEND GOOD TO GO PARTS: all letters of spangram are placed on the grid such that, they're in bounds and no overlaps.
there are notions of randomness when it comes to:
 (1) which orientation to use,
 (2) starting point (at a random col for vertical path, random row for horizontal path), 
 (3) the direction the spangram letters chooses

- ISSUE: there are still a few chances where the spangram generates orphans :/ i am trying to debug [check_no_orphans] 
function to see in what cases they don't work. there is also a limitation on when the spangram is way too long

- PENDING / Currently working on: 
(1) updating game.ml to tie together overall grid generation with the word found record 
(2) debugging the above issues 

- TESTING: made test suites for different modules and functions in tests_strands -- looking to see why running the bisect report is not working