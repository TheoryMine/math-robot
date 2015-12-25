# TheoryMine Math-Robot for Isabelle 2015

This repository contains the TheoryMine code to synthesise new datatypes, functions, and theorems using [IsaPlanner and IsaCoSy](https://github.com/TheoryMine/IsaPlanner).

## Assumed setup

 * Isabelle installed in: `/usr/local/Isabelle2015`
 * isaplib installed in: `/usr/local/Isabelle2015/contrib/isaplib`
 * IsaPlanner installed in: `/usr/local/Isabelle2015/contrib/IsaPlanner`


## Generate the background heap/session

```
export ISAPLANNER_DIRECTORY=/usr/local/Isabelle2015/contrib/IsaPlanner

isabelle build \
  -d $ISAPLANNER_DIRECTORY \
  -d . \
  -b HOL-TheoryMine
```


## Run synthesis:

From this directory (`math-robot`):
 1. Edit the run_synth.thy file.
 2. Run this command:

```
isabelle build \
  -d $ISAPLANNER_DIRECTORY \
  -d . \
  -b RunSynth
```

If there are problems, you can check the logs with something like this:
```
tail -n 1000 -f ~/.isabelle/Isabelle2015/heaps/polyml-5.5.2_x86-darwin/
```

Generated theories/theorems are outputed into a directory called `output`.


## Uploading theorems

Assuming that you've generated theorems with the above command (or
interactively), the generated theorems will be in a directory named `output`.

```
php upload_theorems.php output theorymine.co.uk vtppassU1
```

## Editing the code

To startup Isabelle locally with jEdit to make edits to theory mine (assuming you are happy with your HOL-IsaPlannerSession):

```
isabelle jedit -n -l HOL-IsaPlannerSession -d $ISAPLANNER_DIRECTORY -d .
```

