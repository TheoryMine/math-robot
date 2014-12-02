theory tm_thms2
imports "fungen_T_1"
begin


ML {*
val lemmas = Conjdb_CtxtInfo.lemmas_in_ctxt ctxt';
val output = SynthOutput.Ctxt.get ctxt';

val lemmas = map (fst o snd) (Goaln.NTab.list_of (Conjdb_CtxtInfo.lemmas_in_ctxt ctxt'));
(* val conjs = SynthOutput.get_conjs (SynthOutput.Ctxt.get ctxt'); *)
val thms = SynthOutput.get_thms (SynthOutput.Ctxt.get ctxt');
*}

.

ML {*
  val thm_synth : prover_f -> cexfinder_f -> result_config_f 
      -> size_restr
      -> ConstraintParams.T * Proof.context 
      -> ConstraintParams.T * Proof.context


(* synthesise functions *)
(* assumes not mutualy recursive! i.e. only one recursive type name *)
fun synth_isacosy_level1_theorems_for_fun n thy = 
    let 
      val ctxt = ProofContext.init_global thy 

      (* get info about the recursively defined function symbol *)
      (* assumes not mutualy recursive! i.e. only one recursive type name *)
      val [(rec_typn,_)] = TM_Data.Fun.Thy.rectyps_of_fname thy n; 
      val (fsym,fty) = TM_Data.Fun.Thy.constinfo_of_fname thy n;
      val thms = TM_Data.Fun.Thy.defthms_of_fname thy n;

      (* set constraint params; synth with func symbol and constructors of recursive arg *)
      val cparams = 
          ConstraintParams.empty 
            |> ThyConstraintParams.add_eq ctxt
            |> ((ConstraintParams.add_consts o map Term.dest_Const) [Const (fsym,fty)])
            |> ConstraintParams.add_thms ctxt thms
            |> ThyConstraintParams.add_datatype ctxt rec_typn;

      val _ = ConstraintParams.print (ProofContext.init_global thy) cparams;

      (* set the top part of the term (conjectures about "=") *)
      val thy_constraints = (Constraints.init ctxt cparams);
      val top_term = Thm.term_of @{cpat "op = :: ?'a => ?'a => bool"};
      val top_const = (Constant.mk (fst (Term.dest_Const top_term)));

      val prepared_thy = (* prepare the proof tool(s) *)
          thy |> Context.theory_map (WRulesGCtxt.init NONE)
              |> fold (Context.theory_map o WRulesGCtxt.add_wrule_thm) thms;
    in
       ConstrSynthesis.synthesise_terms 
         top_const (* top constant *)
         ConstrSynthesis.VarAllowed.is_hole_in_lhs (* where are free vars allowed *)
         (3,12) (* min and max size of synthesised terms *)
         ((length (fst (Term.strip_type fty))) + 1) (* max vars = nargs + 1 *)
         prepared_thy (* initial theory *)
         thy_constraints (* initial theory constraints *)
    end;
*}




ML {*
  fun prove_from_method ctxt0 method conjecture = 
      let val frees = [] |> Term.add_frees conjecture |> map fst in
        ctxt0
          |> Variable.add_fixes frees
          |> snd
          |> Proof.theorem NONE (K I) [[(conjecture, [])]]
          |> Proof.apply method
          |> Seq.hd
          |> `Proof.goal 
          ||> Proof.global_done_proof
          |> (fn ({context,facts,goal},ctxt) => 
                 if 0 = Thm.nprems_of goal 
                 then SOME (goal
                              |> Goal.finish ctxt
                              |> Thm.check_shyps (Variable.sorts_of ctxt)
                              |> Assumption.export false ctxt ctxt0
                              |> single
                              |> Variable.export ctxt ctxt0 
                              |> hd
                              |> Drule.zero_var_indexes)
                 else NONE)
      end
*}


ML {*

val ctxt = @{context};

fun isap_tac ctxt rtech th = 
    let 
      val conjecture = Logic.get_goal (Thm.prop_of th) 1;
      val g = "g"
      val (init_goal,pp) = PPlan.conj_term_at_top (g,conjecture) (PPlan.init ctxt)
  in
    (RState.init_from_pp pp)
      |> RState.set_goalnames [init_goal]
      |> RState.set_rtechn (SOME rtech)
      |> GSearch.depth_fs (fn rst => is_none (RState.get_rtechn rst) 
                           andalso RstPP.solved_all_chk rst) RState.unfold
      |> Seq.map (fn rst => RstPP.result_thm rst g)
      |> Seq.map (fn th2 => th2 RS th) (* apply resulting theorem *)
  end;

fun ripple_meth ctxt = Method.METHOD (K (isap_tac ctxt (RTechnEnv.map_then RippleLemCalc.induct_ripple_lemcalc)));
val ripple_meth_text = Method.Basic ripple_meth;

*}



ML {*
fun synth_eq_conjs thy max_vars fname thms size =
  let 
    val ctxt = ProofContext.init_global thy 

    (* get info about the recursively defined function symbol *)
    (* assumes not mutualy recursive! i.e. only one recursive type name *)
    val [(rec_typn,_)] = TM_Data.Fun.Thy.rectyps_of_fname thy fname; 
    val (fsym,fty) = TM_Data.Fun.Thy.constinfo_of_fname thy fname;

    (* set constraint params; synth with func symbol and constructors of recursive arg *)
    val cparams = 
        ConstraintParams.empty 
          |> ThyConstraintParams.add_eq ctxt
          |> ((ConstraintParams.add_consts o map Term.dest_Const) [Const (fsym,fty)])
          |> ConstraintParams.add_thms ctxt thms
          |> ThyConstraintParams.add_datatype ctxt rec_typn;

    (* val _ = ConstraintParams.print (ProofContext.init_global thy) cparams; *)

    (* set the top part of the term (conjectures about "=") *)
    val thy_constraints = (Constraints.init ctxt cparams);
    val top_term = Thm.term_of @{cpat "op = :: ?'a => ?'a => bool"};
    val top_const = (Constant.mk (fst (Term.dest_Const top_term)));
  in 
    ConstrSynthesis.synthesise_terms' 
      top_const (* top constant *)
      ConstrSynthesis.VarAllowed.is_hole_in_lhs (* where are free vars allowed *)
      size (* size of synthesised terms *)
      max_vars
      thy (* initial theory *)
      thy_constraints (* initial theory constraints *)
    |> Seq.map ConstrSynthesis.get_term;
  end;

*}


ML {* 

(* ------------------------------------------------------------------------*)
*}

lemmas l = fdjkfdjfdkj djkdfkjfd dfjkdfkj add_Suc add_Zero ... 

ML {* 



((length (fst (Term.strip_type fty))) + 1) (* max vars = nargs + 1 *)



fun synth thy fname =
  let 
    val max_size = 14;
    val max_vars = 3;
    val sizes = (4 upto max_size)

    val def_thms = TM_Data.Fun.Thy.defthms_of_fname thy fname;

    val conjs = synth_eq_conjs thy max_vars fname thms size =

    val prepared_thy = (* prepare the proof tool(s) *)
        thy |> Context.theory_map (WRulesGCtxt.init NONE)
            |> fold (Context.theory_map o WRulesGCtxt.add_wrule_thm) thms;

*}




.



.


ML {*
  val (c,ty) = TM_Data.Fun.Thy.constinfo_of_fname @{theory} (Fn.mk "f_2");
  val thms = TM_Data.Fun.Thy.defthms_of_fname @{theory} (Fn.mk "f_2");
  val x = Seq.list_of (Def_Utils.neglects_argument_raw ctxt ripple_meth_text 5 5 (Const (c,ty)));
*}


.

ML {* 
      val thms = TM_Data.Fun.Thy.defthms_of_fname thy n;

      Proof_Utils.local_prove_with_time_limit ripple_meth_text t 5;

*}


end;

