theory tm_theorems
imports "TM_Data"
begin

ML {*
fun synth_isacosy_level1_theorems_for_fun fname ctxt =
  let
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
          (SynthInterface.Prover (TM_Provers.ripple_prover
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
(* get the TheoryMine theorems from the context *)
fun thms_of_synth_context ctxt =
    let
      val lemmas = map (pair "induction and rippling" o fst o snd)
                       (Goaln.NTab.list_of (Conjdb_CtxtInfo.lemmas_in_ctxt ctxt));
      val thms = SynthOutput.get_thms (SynthOutput.Ctxt.get ctxt);
    in (lemmas, thms) end;
*}

end
