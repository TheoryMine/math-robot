theory "run_synth_funs2"
imports "tm_datatypes" "tm_functions"
begin

-- "Setup synthesis
    (mod,remainder), for generating only a small filtered set. 
    (0,1) to generate all functions
    (0,200) to generate 1st, 201st, 401st,... etc, i.e. 1 in every 200 functions
    (1,200) to generate 2nd, 202nd, 402nd,... etc, i.e. 1 in every 200 functions, but offset by 1"
ML {* 
  val dname_to_synth_funs_for = (Tn.mk "T_6");
  val mod_n = 1;
  val rem_n = 0;
*}
-- "Examine/print the datatypes in the context"
ML {* TM_Data.DType.Ctxt.print_dtyp @{context} dname_to_synth_funs_for; *}

-- "Generate/synthesise functions"
setup {* fun_synth (rem_n,mod_n) dname_to_synth_funs_for *}

ML {* 
  (pwriteln o Pretty.str) ("well-defined functions synthesised: " ^ Int.toString (!goodn));
  (pwriteln o Pretty.str) ("triv argument neglecting ignored: " ^ Int.toString (!trivn));
*}

-- "Examine/print the functions in the context"
ML {* TM_Data.Fun.Ctxt.print @{context} *}

-- "Partition functions into argument neglecting and others (not currently used)"
ML {*
val fntab = TM_Data.Fun.Ctxt.get_fntab @{context};
val ((neglect_fs,maybe_neglect_fs,fs)) =
    Fn.NTab.fold 
      (fn (fname,(x as (c,ty),eqs)) => fn (neglect_fs,maybe_neglect_fs,fs) => 
       let (* prepare the proof tool(s) *)
         val prover_timeout = 5; (* in seconds *)
         val counterex_timeout = 5; (* in seconds *)
         val neglect_infos = Seq.list_of 
             (DB_Def_Utils.neglects_argument_raw 
               @{context} TM_Provers.ripple_meth_text prover_timeout counterex_timeout (Const x));
       in
        case map_filter (fn (t,SOME thm) => SOME thm | _ => NONE) neglect_infos
          of [] => (case map_filter (fn (t,NONE) => SOME t | _ => NONE) neglect_infos 
                      of [] => (neglect_fs,maybe_neglect_fs,fname::fs)
                       | l => (neglect_fs,(fname,l)::maybe_neglect_fs,fs))
           | l => ((fname,l)::neglect_fs,maybe_neglect_fs,fs)
       end)
       fntab
       ([],[],[]);
*}

end;
