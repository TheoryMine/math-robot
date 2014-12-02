theory "run_synth_thms"
imports "tm_theorems" "run_synth_funs"
begin

(* run theorem synthesis for all synthesised functions defined in context TM_Data *)

ML {* 
  TM_Data.DType.Ctxt.print @{context};
  TM_Data.Fun.Ctxt.print @{context};
*}

ML {* 
(* get all functions names in this Isabelle context *)
  val fnames = (map fst (Fn.NTab.list_of (TM_Data.Fun.Ctxt.get_fntab @{context})))
*}
ML {*
(* synthesise, then print the theory/theorems to a php file. *)
val ctxt = @{context};
val results =
   fold
     (fn n => 
         let val (cparams,ctxt) = synth_isacosy_level1_theorems_for_fun n ctxt
             val [rec_tn] = Tn.NSet.list_of (TM_Data.Fun.Ctxt.rectns_of_fname ctxt n); 
             val _ = PHPSynthOutput.phpify_theory ctxt rec_tn n;
         in I end)
     fnames
     ();
*}

end;
