theory "conj_capture"
imports "tm_datatypes" "tm_functions" "tm_theorems"
begin

(* fun function and theorem synthesis *)

-- "Datatype to run synthesis on: functions will be recursive on this type."

ML {* TM_Data.DType.Ctxt.print @{context} *}

(* T_1 to T_15 *)
ML {* 
  val dname_to_synth_funs_for = (Tn.mk "T_1");
*}



-- "Setup synthesis
    (rem_n,mod_n), for generating only a small filtered set. 
    (0,1) to generate all functions
    (0,200) to generate 1st, 201st, 401st,... etc, i.e. 1 in every 200 functions
    (1,200) to generate 2nd, 202nd, 402nd,... etc, i.e. 1 in every 200 functions, but offset by 1"
ML {* 
  val rem_n = 0;
  val mod_n = 100;
*}

-- "the number of functions to skip over; typically the biggest number of function in the output
    directory (so that we can keep on discovering new stuff) 
    IMPROVE: could look at filenames and work this out automatically... " 
ML {* 
  val skip_first_n = 64;
*}

-- "Function which captures the context etc when generating function of datatypes"
ML{*
val (stuff: ((theory*int*TnFnRel.Cod.name) list) Unsynchronized.ref) = Unsynchronized.ref [] ;


fun capture_fun (thy:theory) (n:int) (fname:TnFnRel.Cod.name) = stuff := (!stuff) @ [(thy,n,fname)];

  fun run_synth dn nargs thy = 
      let
        val (_,funspec_seq) =
            Seq.chop skip_first_n 
              (number_seq (level1_function_seq_of_datatype @{context} dn nargs));
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
                               | _ => (SynthBug("Unkown error. "))
                 in case result of 
                      Synthesised(fnm,thy2) => 
                        ((tracing ("Syntheises good function (" ^ (Int.toString n) ^ "): " ^ (Fn.dest fnm) ^ " \ndef: " ^ 
                                   (Pretty.string_of (pretty_synthd_func (ProofContext.init_global thy2) x)));
                          capture_fun thy2 n fnm; 
                          (goodn + 1,ignoredn,badfunn,funerrorl,prferrorl))
                        handle Exn.Interrupt => raise Exn.Interrupt
                           | _ => (goodn,ignoredn,badfunn,funerrorl,n::prferrorl))
                    | SynthBug(err_msg) => (tracing err_msg;  (goodn,ignoredn,badfunn,n::funerrorl,prferrorl))
                    | SynthBadFun(err_msg,thy2) => (tracing err_msg;  (goodn,ignoredn,1 + badfunn,funerrorl,prferrorl))
                    | SynthTrivial => (goodn,ignoredn + 1,badfunn,funerrorl,prferrorl)
                 end)
              (* take only 1 in n of the functions, offset by filteroffset *)
              (filterseq_1_in_n (Unsynchronized.ref rem_n) mod_n funspec_seq)
              (0,0,0,[],[])
      end;
*}

-- "generates functions"
ML {* 
  stuff := [];
  val results = run_synth dname_to_synth_funs_for 1 @{theory};
*}


-- "generates a string of all datatypes and functions"
ML{*
fun dtyp_and_fns_to_string dname fns =
  let fun fn_as_str (x,y,z) = PrintToThy.string_of_fn  (ProofContext.init_global x)
      val all_sn_as_strf = fold (fn els => fn str => str ^ "\n\n" ^ fn_as_str els) fns;
      val dtps_str = PrintToThy.string_of_dtyp @{context} dname
   in 
    all_sn_as_strf dtps_str
   end;

fun dtyp_and_fns_to_string_of_stuff () = 
  dtyp_and_fns_to_string dname_to_synth_funs_for (!stuff);
*}

-- "generates a string which adds function defs as wave rules"
ML{*
 fun add_one_fun_as_wrules fname = "\ndeclare " ^ (Fn.NTab.string_of_name fname) ^".simps[wrule]";

 fun add_funs_as_wrules xs =
    (fold (fn (_,_,fname) => (fn str => str ^ add_one_fun_as_wrules fname)) xs "\n") ^ "\n\n";

 fun add_get_funs_as_wrules () = add_funs_as_wrules (!stuff);

*}

-- "Return a pair holding list of all open conjectures and thms of a function as a term"
-- "assumes: use of @{context} and function prove_and_capture : context -> string list -> rstate"
ML {*
 fun synth_and_get_open_conj_of_fun fname ctx = 
   let  fun try_unvarify t = Logic.unvarify_global t handle _ => t;
        val (_,ctx') =  synth_isacosy_level1_theorems_for_fun fname (ProofContext.init_global ctx);
       val cons = SynthOutput.Ctxt.get ctx'
       val mlstart = "ML{"^"* ";
       val mlend = " *"^"}";
       fun str_of_term t = (PrintToThy.term_to_str ctx' t);
       fun str_of_term_app app t = mlstart ^ app ^ " [\"" ^ (str_of_term t) ^ "\"]" ^ mlend ^ "\n";
       fun str_of_terms_app app ts = fold (fn t => fn str => str ^ (str_of_term_app app t)) ts "";
       val open_conjs = SynthOutput.get_conjs cons
       val conj_comment = "\n\n (* open conjectures for function: " ^  (Fn.NTab.string_of_name fname)  ^ "*)\n"
       val conj_str = conj_comment ^ (str_of_terms_app "prove_and_capture @{context}" open_conjs)
       val thms = map (fn (_,t) => try_unvarify (Thm.full_prop_of t)) (SynthOutput.get_thms cons) (* not sure if it should be full_prop_of *)
       val thm_comment = "\n\n (* theorems proven for function: " ^  (Fn.NTab.string_of_name fname)  ^ "*)\n"
       fun thm_str_of_term_app t = "lemma [wrule]: \"" ^ (str_of_term t) ^ "\"\nsorry\n\n";
       fun thm_str_of_terms_app ts = fold (fn t => fn str => str ^ (thm_str_of_term_app t)) ts "";
       val thm_str = thm_comment ^ (thm_str_of_terms_app thms)
   in
     (conj_str,thm_str)
   end;
*}

-- "returns the list of all open conjectures and thms"
ML{*
 fun synth_and_get_open_conj conjs =
   fold
    (fn (ctx,_,fname) => fn (conj_str,thm_str) => 
         let val (newconj,newthm) = synth_and_get_open_conj_of_fun fname ctx
         in (conj_str ^ newconj,thm_str ^ newthm) end)
    conjs
    ("","");
  
  fun synth_and_get_open_conj_from_stuff () =
    synth_and_get_open_conj (!stuff);
*}

-- "functions to write file"
ML{*
fun write_file filename body = 
  let
     val _ = writeln ("path: " ^ pwd());
     val outs = TextIO.openOut filename
  in
     TextIO.output (outs, body); 
     TextIO.closeOut outs
  end;

fun make_theory_file () =
  let val defs = dtyp_and_fns_to_string_of_stuff ()
      val name = Tn.string_of_name dname_to_synth_funs_for
      val wrules = add_get_funs_as_wrules ()
      val (conjs,thms) = synth_and_get_open_conj_from_stuff ()
      val body =  defs ^ wrules ^  "\n(*\n" ^ thms ^ "\n*)\n" ^ conjs
      val pre = "theory " ^ name ^ "\nimports IsaP \nuses \"failure_capture.ML\"\nbegin\n\n"
  in 
    write_file (name ^ ".thy") (pre ^ body ^ "\n\nend")
  end;
*}

-- "creates the actual theory"
ML{*
make_theory_file ();
*}

end
