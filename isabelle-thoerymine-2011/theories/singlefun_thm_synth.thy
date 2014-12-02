theory "thmsynth_f_1"
imports "../tm_theorems" "fungen_T_1"
begin

ML {* TM_Data.DType.Ctxt.print @{context} *}
ML {* TM_Data.Fun.Ctxt.print @{context} *}

ML {* 
  val (proj_fs,maybe_proj_fs,non_proj_fs) = xresults;
*}

(* use "php_synth_output.ML" *)
(* 
use "prettification.ML" 
use "php_synth_output.ML" 
*)

ML {*
  val n = Fn.mk "f_85";
  val ctxt = @{context};
*}

ML {* TM_Data.Fun.Ctxt.defthms_of_fname @{context} (Fn.mk "f_85") *}

ML {*
  val (cparams,ctxt) = synth_isacosy_level1_theorems_for_fun n ctxt;
*}

ML {*
  val [rec_tn] = Tn.NSet.list_of (TM_Data.Fun.Ctxt.rectns_of_fname ctxt n); 
  val _ = PHPSynthOutput.phpify_theory ctxt rec_tn n;
*}

end;
