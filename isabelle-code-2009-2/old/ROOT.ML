(*
start IsaPlanner from IsaPlanner/src/quicktest.ML

To run the program from Isabelle use the following line:

PolyML.use "/home/s0566840/project-code/IsaP-trunk/IsaPlanner/src/dev/vanity_theorem_proving/TEMP_ROOT.ML";

*)

(*MyMain is a theory file *)

use_thy "MyMain";
val thry = theory "MyMain";

(*This is a file written by Moa to get some statistrics from IsaCoSy *)
(* use "record_stats.ML"; *)

(*This is the rest of the code I wrote*)

use "list_of_var";

use "help_functions";

use "theory_edit";
use "generate_data";

use "make_rhs";
use "make_lhs";
use "generate_new_theory";

(*use "examples";*)
