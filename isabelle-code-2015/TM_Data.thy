theory TM_Data
imports TM_Names argument_neglecting tm_provers Main
keywords
"display_mdata" :: diag
begin

text {* Data generation code *}
ML_file "datagen.ML"
text {* datatypes with named constructors *}
ML_file "named_dtype.ML"
-- "extra synthesis code for constructing function definitions"
ML_file "isacosy_synth_fundefs.ML"
text {* This code defines TheoryMine's representation of datatypes
  that lives in an Isabelle theory. In particular, it has its own
  name-space for data types and constructors. These are based on
  name-tables. This is to support the programatic creation of new
  names for datatypes and constructors. *}
ML_file "tm_data.ML"
(* convert datatypes and functions to ML serialisations *)
ML_file "ml_serialisation.ML"
ML_file "prettification.ML"
ML_file "php_synth_output.ML"
text {* Pretty printing to create Isabelle theories as output *}
ML_file "PrintToThy.ML"
 
ML {* (* set Toplevel.debug; *) *}

ML {*
val _ = Outer_Syntax.command 
          @{command_keyword "display_mdata"}
          "Display TheoryMine datatypes"
          (Scan.succeed (Toplevel.keep (TM_Data.DType.Ctxt.print o Toplevel.context_of)))
*}

display_mdata

(* general utlity stuff *)
ML {*
  (* filter; take 1 in N *)
  fun filter_1_in_n i n = 
      (i := (!i) - 1; filter (fn x => (i := (!i) + 1; Int.mod(!i,n) = 0)));

  fun filterseq_1_in_n i n = 
      (i := (!i) - 1; Seq.filter (fn x => (i := (!i) + 1; Int.mod(!i,n) = 0)));
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