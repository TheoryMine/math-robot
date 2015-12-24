# TheoryMine Math-Robot for Isabelle 2015

To generate the background heap/session:

```
export ISAPLANNER_DIRECTORY=../../IsaPlanner/

isabelle build \
  -d $ISAPLANNER_DIRECTORY \
  -d . \
  -b HOL-TheoryMine
```

To run synthesis from the command line:

1. Edit the run_synth.thy file.

2. Run this command:

```
isabelle build \
  -d $ISAPLANNER_DIRECTORY \
  -d . \
  -b RunSynth
```

Generated theories/theorems are outputed into a directory called `output`.

To startup Isabelle locally with jEdit to make edits to theory mine (assuming you are happy with your HOL-IsaPlannerSession):

```
isabelle jedit -n -l HOL-IsaPlannerSession -d $ISAPLANNER_DIRECTORY -d .
```
