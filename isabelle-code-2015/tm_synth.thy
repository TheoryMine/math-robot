theory "tm_synth"
imports "tm_datatypes" "tm_functions" "tm_theorems"
begin

ML {*
(* synthesises and saves theorems for a function to a file. *)
fun synth_and_save_thms_for_fun thy fname =
    let val ctxt = Proof_Context.init_global thy
        val (cparams,ctxt) = synth_isacosy_level1_theorems_for_fun fname ctxt
        val [rec_tn] = Tn.NSet.list_of (TM_Data.Fun.Ctxt.rectns_of_fname ctxt fname);
        val _ = PHPSynthOutput.phpify_theory ctxt rec_tn fname;
    in () end
*}

ML {*
(* Synthesise functions recursive for datatype dn,
   which have nargs other argument. This includes synthesis of
   theorems about these functions.

  To generating only a small filtered set:
     skip_first_n : int = skip first n functions (used to avoid creating
         the name functions again on a subsequent run)
     fun_generate_limit : int = only generate this many few functions.
     rem_n : int = only use functions that moduldo |mod_n| have
         remainder index of |rem_n|
     mod_n : int = make a modulo value for functions so you can filter
         which you select from using rem_n:
         (rem_n,mod_n):
           (0,1) to generate all functions
           (0,200) to generate 1st, 201st, 401st,... etc, i.e. 1 in every 200
               functions
           (1,200) to generate 2nd, 202nd, 402nd,... etc, i.e. 1 in every 200
               functions, but offset by 1"
     nargs : int = number of other (non-rec) arguments; 1 = will
         generate arity 2 functions.

  Returns:
   goodn, = Number of good generated functions.
   ignoredn, = Number of ignored (trivial) functions.
   badfunn, = Number of non trivial recursive functions generated.
   funerrorl, = Number of functions that generated an error during function
       definition.
   prferrorl = Number of functions that produces a problem during proof of
       theorems about the function (e.g. used to much memory).
*)
  fun run_synth dn (skip_first_n, fun_generate_limit, rem_n, mod_n)
                nargs thy =
      let
        val funspec_seq =
        (level1_function_seq_of_datatype @{context} dn  nargs)
        |> number_seq
        |> Seq.chop skip_first_n
        |> snd
        |> Seq.take fun_generate_limit
      in
        seq_fold
          (fn (n,x as ((s,ty,rty),eqs)) =>
           fn (goodn,ignoredn,badfunn,funerrorl,prferrorl) =>
           let val result =
             (if (FastArgNeglect.syntactically_arg_neglecting_fundef eqs)
                 orelse (FastArgNeglect.pattern_arg_neglecting_fundef eqs)
                 orelse (List.all (not o has_non_type_const) eqs)
              then SynthTrivial
              else (let val (fnm, (err_opt, thy2)) =
                            TM_Data.add_new_function'
                              (Fn.mk ("f_" ^ (Int.toString goodn))) x thy
                    in if is_none err_opt then Synthesised(fnm,thy2)
                       else SynthBadFun(the err_opt, thy2) end))
              (* handle ERROR s => (SynthBug("ERROR exception: " ^ s))
                   | Exn.Interrupt => raise Exn.Interrupt
                   | _ => (SynthBug("Unkown error. ")) *)
           in case result of
                Synthesised(fnm,thy2) =>
                  ((tracing ("Synthesised good function (" ^ (Int.toString n)
                             ^ "): " ^ (Fn.dest fnm) ^ " \ndef: " ^
                             (Pretty.string_of (pretty_synthd_func
                               (Proof_Context.init_global thy2) x)));
                    synth_and_save_thms_for_fun thy2 fnm;
                    (goodn + 1,ignoredn,badfunn,funerrorl,prferrorl))
                  (* handle Exn.Interrupt => raise Exn.Interrupt
                     | _ => (goodn,ignoredn,badfunn,funerrorl,n::prferrorl) *)
                  )
              | SynthBug(err_msg) =>
                (tracing err_msg;
                  (goodn,ignoredn,badfunn,n::funerrorl,prferrorl))
              | SynthBadFun(err_msg,thy2) =>
                (tracing err_msg;
                  (goodn,ignoredn,badfunn + 1,funerrorl,prferrorl))
              | SynthTrivial =>
                (goodn,ignoredn + 1,badfunn,funerrorl,prferrorl)
           end)
        (* take only 1 in n of the functions, offset by filteroffset *)
        (filterseq_1_in_n (Unsynchronized.ref rem_n) mod_n funspec_seq)
        (0,0,0,[],[])
      end;
*}

end
