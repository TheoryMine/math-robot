header{* Making Datatypes *}
theory TM_Data
imports TM_Names argument_neglecting tm_provers
uses ("datagen.ML") 
     ("named_dtype.ML")
     ("isacosy_synth_fundefs.ML")
     ("tm_data.ML")
     ("ml_serialisation.ML")
     ("prettification.ML")
     ("php_synth_output.ML")
     ("PrintToThy.ML")
begin
 
ML {* (* set Toplevel.debug; *) *}

text {* Data generation code *}
use "datagen.ML"

text {* datatypes with named constructors *}
use "named_dtype.ML"

-- "extra synthesis code for constructing function definitions"
use "isacosy_synth_fundefs.ML"

text {* This code defines TheoryMine's representation of datatypes
  that lives in an Isabelle theory. In particular, it has its own
  name-space for data types and constructors. These are based on
  name-tables. This is to support the programatic creation of new
  names for datatypes and constructors. *}
use "tm_data.ML"

-- "Create the display command IMPROVE: without keywords this is basically useless."
ML {*
local 
  val displayf = Scan.succeed (Local_Theory.target 
        (fn ctxt => (TM_Data.DType.Ctxt.print ctxt; ctxt)))
  val kind = Keyword.thy_decl
in 
  val _ = Outer_Syntax.local_theory "display_mdata" "Display TheoryMine datatypes" kind displayf
end;
*}
(* this should work, but raises an outer syntax error...
display_mdata;
*)

(* general utlity stuff *)
ML {*
  (* filter; take 1 in N *)
  fun filter_1_in_n i n = 
      (i := (!i) - 1; filter (fn x => (i := (!i) + 1; Int.mod(!i,n) = 0)));

  fun filterseq_1_in_n i n = 
      (i := (!i) - 1; Seq.filter (fn x => (i := (!i) + 1; Int.mod(!i,n) = 0)));
*}

(* Pretty printing to create Isabelle theories as output *)
use "PrintToThy.ML"

(* convert datatypes and functions to ML serialisations *)
use "ml_serialisation.ML"

use "prettification.ML"

use "php_synth_output.ML"

ML {*
  Multithreading.max_threads := 1;
  Goal.parallel_proofs := 0;
*}

(* Basic consts for synthesis of functions and theorems *)
ML {*
  val base_dtypes = [@{typ "nat"}, @{typ "bool"}];
  (* IMPROVE: lookup below from datatype package: not sure below are needed... *)
  val base_consts = map (Term.dest_Const) 
                        [@{term "Suc"}, @{term "0 :: nat"}, @{term "True"}, @{term "False"}];
  val base_const_names = map fst base_consts;
*}

end