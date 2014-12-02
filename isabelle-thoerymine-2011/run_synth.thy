theory "run_synth"
imports "tm_datatypes" "tm_functions" "tm_theorems"
begin

(* fun function and theorem synthesis *)

-- "Setup synthesis
    (remainder,mod), for generating only a small filtered set. 
    (0,1) to generate all functions
    (0,200) to generate 1st, 201st, 401st,... etc, i.e. 1 in every 200 functions
    (1,200) to generate 2nd, 202nd, 402nd,... etc, i.e. 1 in every 200 functions, but offset by 1"
ML {* 
  val dname_to_synth_funs_for = (Tn.mk "T_1");
  val rem_n = 0;
  val mod_n = 1;
*}
-- "Examine/print the datatypes in the context"
ML {* TM_Data.DType.Ctxt.print_dtyp @{context} dname_to_synth_funs_for; *}

ML {*
(* synthesises and saves theorems for a function to a file. *)
fun synth_and_save_thms_for_fun thy n fname = 
    let val ctxt = ProofContext.init_global thy
        val (cparams,ctxt) = synth_isacosy_level1_theorems_for_fun fname ctxt
        val [rec_tn] = Tn.NSet.list_of (TM_Data.Fun.Ctxt.rectns_of_fname ctxt fname); 
        val _ = PHPSynthOutput.phpify_theory ctxt rec_tn n fname;
    in () end
*} 

ML {* 
  val x = Exn.Interrupt;
*}

ML {* 
  (* Synthesise functions recursive on dn, which have nargs other argument. Includes synthesis of 
     theorems about these functions. 
       nargs : int = number of other (non-rec) arguments
  *)
  fun run_synth dn nargs thy = 
      let
        val funspec_seq =
            number_seq (level1_function_seq_of_datatype @{context} dn nargs);
      in 
        seq_fold (fn (n,x as ((s,ty,rty),eqs)) => fn (goodn,ignoredn,badfunn,funerrorl,prferrorl) => 
                 let val result = 
                         (if (FastArgNeglect.syntactically_arg_neglecting_fundef eqs)
                             orelse (DB_Def_Utils.pattern_arg_neglecting_fundef eqs)
                             orelse (List.all (not o has_non_type_const) eqs)
                          then SynthTrivial
                          else (let val (fnm, (err_opt, thy2)) =  
                                        TM_Data.add_new_function' (Fn.mk ("f_" ^ (Int.toString goodn))) x thy
                                in if is_none err_opt then Synthesised(fnm,thy2)
                                   else SynthBadFun(the err_opt, thy2) end))
                          handle ERROR s => (SynthBug("ERROR exception: " ^ s))
                               | Exn.Interrupt => raise Exn.Interrupt
                               | _ => (SynthBug("Unkown error: "))
                 in case result of 
                      Synthesised(fnm,thy2) => 
                        ((tracing ("Syntheises good function (" ^ (Int.toString n) ^ "): " ^ (Fn.dest fnm) ^ " \ndef: " ^ 
                                   (Pretty.string_of (pretty_synthd_func (ProofContext.init_global thy2) x)));
                          synth_and_save_thms_for_fun thy2 n fnm; 
                          (goodn + 1,ignoredn,badfunn,funerrorl,prferrorl))
                        handle Exn.Interrupt => raise Exn.Interrupt
                           | _ => (goodn,ignoredn,badfunn,funerrorl,n::prferrorl))
                    | SynthBug(err_msg) => (tracing err_msg;  (goodn,ignoredn,badfunn,n::funerrorl,prferrorl))
                    | SynthBadFun(err_msg,thy2) => (tracing err_msg;  (goodn,ignoredn,n::badfunn,funerrorl,prferrorl))
                    | SynthTrivial => (goodn,ignoredn + 1,badfunn,funerrorl,prferrorl)
                 end)
              (* take only 1 in n of the functions, offset by filteroffset *)
              (filterseq_1_in_n (ref rem_n) mod_n funspec_seq)
              (0,0,[],[],[])
      end;
*}

ML {* 
  val results = run_synth dname_to_synth_funs_for 1 @{theory};
*}

ML {* 
  val (goodn,ignoredn,n::badfunn,funerrorl,prferrorl) = results;
*}


-- "Examine/print the functions in the context"
ML {* TM_Data.Fun.Ctxt.print @{context} *}

-- "Partition functions into argument neglecting and others (not currently used)"
ML {*
val fntab = TM_Data.Fun.Ctxt.get_fntab @{context};
val ((buggy_fs,neglect_fs,maybe_neglect_fs,fs)) =
    Fn.NTab.fold 
      (fn (fname,(fconst as (c,ty),eqs)) => fn (buggy_fs,neglect_fs,maybe_neglect_fs,fs) => 
       let (* prepare the proof tool(s) *)
         val prover_timeout = 5; (* in seconds *)
         val counterex_timeout = 5; (* in seconds *)
         val neglect_infos = Seq.list_of 
             (DB_Def_Utils.neglects_argument_raw 
               @{context} 
               TM_Provers.ripple_meth_text 
               prover_timeout 
               counterex_timeout 
               (Const fconst));
       in
        case map_filter (fn (t,SOME thm) => SOME thm | _ => NONE) neglect_infos
          of [] => (case map_filter (fn (t,NONE) => SOME t | _ => NONE) neglect_infos 
                      of [] => (buggy_fs,neglect_fs,maybe_neglect_fs,fname::fs)
                       | l => (* generate theorems for maybe neglecting stuff *)
                              (synth_and_save_thms_for_fun @{context} fname;
                               (buggy_fs,neglect_fs,(fname,l)::maybe_neglect_fs,fs)))
           | l => (* generate theorems non-argument neglecting functions *)
                  (synth_and_save_thms_for_fun @{context} fname;         
                   (buggy_fs,(fname,l)::neglect_fs,maybe_neglect_fs,fs))
       end handle _ => (fname::buggy_fs,neglect_fs,maybe_neglect_fs,fs)
       )
       fntab
       ([],[],[],[]);
*}

end;
