theory "run_synth_debug"
imports "tm_synth"
begin


ML {*
Trm.MLSerialise.string_of_term @{term "x :: nat"};
*}

fun f :: "T_10 \<Rightarrow> nat \<Rightarrow> nat"
where 
  "f (C_20 a) b = b"  
| "f (C_19 a b) c = f a 0"

ML {*
val dtyp_nm = (Tn.mk "T_11");
val skip_first_n = 0
val funspec_seq =
        (level1_function_seq_of_datatype @{context} dtyp_nm 1)
        |> number_seq
        |> Seq.chop skip_first_n
        |> snd
        |> Seq.take 20;

val SOME (funspec as (f_id,fundef), more) = Seq.pull funspec_seq;

val eqs = funspec |> snd |> snd;

false = (FastArgNeglect.syntactically_arg_neglecting_fundef eqs)
        orelse (FastArgNeglect.pattern_arg_neglecting_fundef eqs)
        orelse (List.all (not o has_non_type_const) eqs);
*}

ML {*
val (fname, (err_opt, thy2)) = TM_Data.add_new_function'
                              (Fn.mk ("f_" ^ (Int.toString f_id))) fundef @{theory};
*}


ML {*
  fun update_ctxt x = thy2;
*}
setup update_ctxt
ML {* 
  val thy2 = @{theory};
  val ctxt = @{context};
  val dtyp_nm = (Tn.mk "T_11");
  val fname = (Fn.mk ("f_" ^ (Int.toString f_id)))
*}

ML {* TimeLimit.timeLimit *}


ML {* 
  fun dinfos_of_freevars_in_term ctxt t =
      let
        val stab = fold (fn (free, Type(n,ty)) => Symtab.update (n,free))
                   (Trm.frees_of t)
                   Symtab.empty
        val dinfos = map_filter (BNF_LFP_Compat.get_info
                                   (Proof_Context.theory_of ctxt) [])
                                (Symtab.keys stab)
      in dinfos end;

  fun ripple_thms_of_dinfo (info :  Old_Datatype_Aux.info) =
      (#inject info) @ (#distinct info) @ (#case_rewrites info);

  fun finfos_of_consts_in_term ctxt t =
      let
        fun lookup_fun_info (n,ty) = (SOME (Function.get_info ctxt (Const(n,ty))))
          handle Empty => NONE;
        val stab = fold (fn (n, ty) => Symtab.update (n,ty)) (Trm.consts_of t)
                   Symtab.empty
        val finfos = (map_filter lookup_fun_info (Symtab.dest stab))
      in finfos end;

  fun ripple_thms_of_finfo (info : Function.info) = the (#simps info)
      handle Match => (raise ERROR "No Function Info")

  fun ripple_thms_of_term ctxt t =
      (maps ripple_thms_of_dinfo (dinfos_of_freevars_in_term ctxt t))
      @ (maps ripple_thms_of_finfo (finfos_of_consts_in_term ctxt t));

  exception failed_proof_exp of unit;

  fun try_under_timelimit timeOut f a =
        SOME (TimeLimit.timeLimit (Time.fromSeconds timeOut) f a)
        handle TimeLimit.TimeOut => NONE
             | failed_proof_exp _ => NONE;

  (* induction and rippling prover for use with IsaCoSy.
     Time limitted to 5 seconds. *)
  fun ripple_prover rtech ctxt conjecture =
      let
        val _ = Pretty.writeln (Pretty.str "Top level Synth Conjecture: ");
        val _ = conjecture
            |> Proof_Display.pp_term (Proof_Context.theory_of ctxt)
            |> Pretty.writeln;
        val g = "g"
        (* configure prover with dtype theorems *)
        val thms = ripple_thms_of_term ctxt conjecture;

        val prepared_ctxt =
            ctxt |> fold (Context.proof_map o WRulesGCtxt.add_wrule_thm) thms;

        val (init_goal,pp) =
            PPlan.conj_term_at_top (g,conjecture) (PPlan.init prepared_ctxt);

        val final_rsts =
            (RState.init_from_pp pp)
              |> RState.set_goalnames [init_goal]
              |> RState.set_rtechn (SOME rtech)
              |> GSearch.depth_fs (fn rst => is_none (RState.get_rtechn rst)
                                   andalso RstPP.solved_all_chk rst)
                                  RState.unfold;

         val time_limit_in_seconds = 5;
         val proof_thm_opt = 
             case Seq.pull final_rsts of NONE => NONE
             | SOME (rst,_) => SOME ("induction and rippling", RstPP.result_thm rst g);

          (*
            try_under_timelimit time_limit_in_seconds
               (fn final_rsts => case Seq.pull final_rsts
                 of NONE => raise failed_proof_exp ()
                  | SOME (rst,_) => ("induction and rippling",
                                     RstPP.result_thm rst g))
               final_rsts;
*)
         val lemmas =
             map (fn (_, (thm, _)) => ("induction and rippling", thm))
                 (Goaln.NTab.list_of (Conjdb_CtxtInfo.lemmas_in_ctxt ctxt))
      in (proof_thm_opt, lemmas) end;

*}

ML {*
val g = "g"
val conjecture = @{term "HOL.Trueprop (f_1 a b = f_1 a 0)"};
val thms = ripple_thms_of_term ctxt conjecture;
val prepared_ctxt =
            ctxt |> fold (Context.proof_map o WRulesGCtxt.add_wrule_thm) thms;
val (init_goal,pp) =
    PPlan.conj_term_at_top (g,conjecture) (PPlan.init prepared_ctxt);
val rtech = (RTechnEnv.map_then RippleLemCalc.induct_ripple_lemcalc);
val final_rsts =
            (RState.init_from_pp pp)
              |> RState.set_goalnames [init_goal]
              |> RState.set_rtechn (SOME rtech)
              |> GSearch.depth_fs (fn rst => is_none (RState.get_rtechn rst)
                                   andalso RstPP.solved_all_chk rst)
                                  RState.unfold;
val SOME(rst,_) = Seq.pull final_rsts;
*}

ML {* 
val p = RState.get_pplan rst;
val goalthm = Prf.get_alled_goal_thm p g;
val ctxt1 = Prf.get_context p;
val ctxt2 = Config.put quick_and_dirty true ctxt1;
Seq.pull (Skip_Proof.cheat_tac ctxt2 1 goalthm);
*}

ML {*
RstPP.result_thm rst g;
*}

ML {* 
 (ripple_prover (RTechnEnv.map_then RippleLemCalc.induct_ripple_lemcalc))
*}

ML {* 
 val [rec_tn] = Tn.NSet.list_of (TM_Data.Fun.Ctxt.rectns_of_fname ctxt fname);
*}

ML {* 
  val (_,ty) = TM_Data.Fun.Ctxt.constinfo_of_fname ctxt fname
  val typtntab = TM_Data.DType.Ctxt.get_typtntab ctxt
  val all_tns = 
       (Trm.atomic_typconsts_of_typ ty)
         |> map_filter (Symtab.lookup typtntab) 
         |> Tn.NSet.of_list |> Tn.NSet.list_of(* removed dups *)
  val selected_tns = filter (TM_Data.DType.Ctxt.is_tm_rec_tn ctxt) all_tns;
  val thms = (SynthOutput.get_thms (SynthOutput.Ctxt.get ctxt))
  val (_,ty) = TM_Data.Fun.Ctxt.constinfo_of_fname ctxt fname
  val pretty_eqs = Fn.NTab.get (TM_Data.Fun.Ctxt.get_fntab ctxt) fname;
  val x = fname;
*}

ML {*
val (_,t::ts) = (pretty_eqs);
Trm.MLSerialise.string_of_term t;
*}


ML {* 
    (* max_nesting specifies how many times a function may nest with itself.
       If no limit desired, set to NONE. *)
    val size_restr = {max_size = 12, min_size = 4, max_vars = 3, max_nesting = SOME 2};
    val ctxt =
        ctxt |> Context.proof_map (WRulesGCtxt.init NONE)
             |> Conjdb_CtxtInfo.discard_all_in_ctxt
             |> SynthOutput.Ctxt.put SynthOutput.empty

    (* get info about the recursively defined function symbol *)
    (* assumes not mutualy recursive! i.e. only one recursive type name *)
    val [(rec_typn,_)] = TM_Data.Fun.Ctxt.rectyps_of_fname ctxt fname;
    val (fsym,fty) = TM_Data.Fun.Ctxt.constinfo_of_fname ctxt fname;
    val thms = TM_Data.Fun.Ctxt.defthms_of_fname ctxt fname;

    (* set constraint params; synth with func symbol and constructors of recursive arg *)
    val cparams =
        ConstraintParams.empty
          |> ThyConstraintParams.add_eq ctxt
          |> ConstraintParams.add_consts [(fsym,fty)]
          |> ThyConstraintParams.add_datatypes' ctxt
             (Term.body_type fty :: Term.binder_types fty)
          |> ConstraintParams.add_thms ctxt thms
         (*  |> ThyConstraintParams.add_datatype ctxt rec_typn; *)

    val _ = ConstraintParams.print ctxt cparams;

    val timer = Timer.startCPUTimer();
    val (cparams,ctxt) =
        SynthInterface.thm_synth
          (SynthInterface.Prover (ripple_prover
              (RTechnEnv.map_then RippleLemCalc.induct_ripple_lemcalc)))
          (* SynthInterface.rippling_prover *)
          SynthInterface.quickcheck
          (* SynthInterface.wave_rule_config *)
          SynthInterface.try_reprove_config
          SynthInterface.var_allowed_in_lhs
          size_restr
          (Constant.mk @{const_name "HOL.eq"})
          (cparams,ctxt)
    val end_time = Timer.checkCPUTimer timer;

(*
        SynthInterface.thm_synth
          (SynthInterface.Prover (TM_Provers.ripple_prover
              (RTechnEnv.map_then RippleLemCalc.induct_ripple_lemcalc)))
          (SynthInterface.quickcheck)
          (SynthInterface.wave_rule_config)
          SynthInterface.var_allowed_in_lhs
          size_restr
          top_const
          (cparams,ctxt)
*)
  in
    (cparams,ctxt)
  end;
*}

ML {*
val (cparams,ctxt) = synth_isacosy_level1_theorems_for_fun fname ctxt;
*}



ML_file "prettification.ML"
ML_file "php_synth_output.ML"

ML {* 
val x= (map (Pretty.str o PHPSynthOutput.php_dtyp ctxt)
                  selected_tns);
*}

ML {*

val s = Pretty.string_of (Print_Mode.setmp [] (fn () => Pretty.str (StringReformater.string_of_typ ctxt ty)) ());
open StringReformater;
*}


ML {*
stringterm_to_html s;
*}

ML {*
val s = (PHPSynthOutput.php_fun ctxt fname)^(PHPSynthOutput.php_synth_thrms ctxt);
val pretty = Pretty.str s;
((Tn.dest dtyp_nm)^"_"^(Fn.dest fname)^".php");

File_Util.writeStringToFilepath
        {path="./"^((Tn.dest dtyp_nm)^"__"^(Fn.dest fname)^".php"),
         str=(Pretty.string_of pretty)}

*}

ML {* 

PHPSynthOutput.phpify_theory ctxt dtyp_nm fname;

*}

ML {*
*}

(* 

ML {*
val (goodn,
     ignoredn,
     badfunn,
     funerrorl,
     prferrorl) =
  run_synth (Tn.mk "T_10")
            (20,  (* skip first this many functions *)
             1,    (* generate this many new functions *)
             0, 1) (* Generate all functions (those indexes: 0 mod 1) *)
            1      (* one non-recursive argument for the generated functions *)
            @{theory};
*}

ML {*
tracing ("Good Functions: " ^ (Int.toString goodn));
tracing ("Ignored Functions: " ^ (Int.toString ignoredn));
tracing ("Bad Functions: " ^ (Int.toString badfunn));
tracing ("Fun Synth Errors: " ^ (Int.toString (length funerrorl)));
tracing ("Proof Synth Errors: " ^ (Int.toString (length prferrorl)));
tracing ("Synthesis completed.");
*}


ML {*
synth_and_save_thms_for_fun thy2 21 fname;
*}

ML {* 
*}
(* 
ML {*
synth_and_save_thms_for_fun thy2 21 fname;
*}

ML {* 
SynthOutput.Ctxt.get @{context}
*}


theorem "f a 0 = 0"
apply (tactic "DB_TM_Provers.ripple_meth")

apply (ripple_tac)
apply (induct "a")
apply simp
apply simp
done

end
