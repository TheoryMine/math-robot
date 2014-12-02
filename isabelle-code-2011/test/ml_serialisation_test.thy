theory "ml_serialisation_test"
imports "tm_initial/run_synth_funs"
begin

ML {*
val f = ML_Serialisation.lookup_dn_to_ml @{context} (Tn.mk "T_1") 
          |> ML_Serialisation.ml_to_datatype @{context};
*}

ML {*
val f = ML_Serialisation.lookup_fn_to_ml @{context} (Fn.mk "f_1") 
          |> ML_Serialisation.ml_to_function @{context};
*}

ML {*
  ML_Serialisation.lookup_dn_to_ml @{context} (Tn.mk "T_1");
  ML_Serialisation.lookup_fn_to_ml @{context} (Fn.mk "f_1");
*}


end;
