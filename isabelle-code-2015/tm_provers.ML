signature TM_PROVERS =
sig
  exception failed_proof_exp of unit;

  val ripple_prover : RState.rtechn -> Proof.context -> term 
      -> (string * Thm.thm) option (* proof description and thm, if proved, else NONE *)
          * (string * Thm.thm) list; (* lemmas found during proof *)

  (* Generic IsaPlanner tactic from technique which pre-prepares for function defs and datatype 
     defs in the goal waverules *)
  val ripple_tac : Proof.context -> RState.rtechn -> tactic

  (* IsaPlanner's rippling *)
  val ripple_meth : Proof.context -> Method.method
  val ripple_meth_text : Method.text

(* 
  (* Omar's induct auto *)
  val induct_auto_meth : Proof.context -> Method.method
  val induct_auto_meth_text : Method.text
*)
end;

structure DB_TM_Provers 
= struct 

  fun dinfos_of_freevars_in_term ctxt t = 
      let
        val stab = fold (fn (free, Type(n,ty)) => Symtab.update (n,free))
                   (Trm.frees_of t) 
                   Symtab.empty
        val dinfos = map_filter (BNF_LFP_Compat.get_info (Proof_Context.theory_of ctxt) []) 
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

  fun ripple_thms_of_finfo (info : Function.info) = the (#simps info);

  fun ripple_thms_of_term ctxt t = 
      (maps ripple_thms_of_dinfo (dinfos_of_freevars_in_term ctxt t))
      @ (maps ripple_thms_of_finfo (finfos_of_consts_in_term ctxt t));
  
  exception failed_proof_exp of unit;
  
  fun try_under_timelimit timeOut f a = 
        SOME (TimeLimit.timeLimit (Time.fromSeconds timeOut) f a)
        handle TimeLimit.TimeOut => NONE
             | failed_proof_exp _ => NONE;
  
  (* induction and rippling prover for use with IsaCoSy. Time limitted to 5 seconds. *)
  fun ripple_prover rtech ctxt conjecture = 
      let 
        val g = "g"
        (* configure prover with dtype theorems *)
        val thms = ripple_thms_of_term ctxt conjecture;
  
        val prepared_ctxt = 
            ctxt |> fold (Context.proof_map o WRulesGCtxt.add_wrule_thm) thms;
  
        val (init_goal,pp) = PPlan.conj_term_at_top (g,conjecture) (PPlan.init prepared_ctxt)
  
        val final_rsts = 
            (RState.init_from_pp pp)
              |> RState.set_goalnames [init_goal]
              |> RState.set_rtechn (SOME rtech)
              |> GSearch.depth_fs (fn rst => is_none (RState.get_rtechn rst) 
                                   andalso RstPP.solved_all_chk rst) RState.unfold
        
         val time_limit_in_seconds = 5;
         val proof_thm_opt = try_under_timelimit time_limit_in_seconds
               (fn final_rsts => case Seq.pull final_rsts of NONE => raise failed_proof_exp ()
                   | SOME (rst,_) => ("induction and rippling", RstPP.result_thm rst g))
               final_rsts   
  
         val lemmas = map (fn (_, (thm, _)) => ("induction and rippling", thm))
                          (Goaln.NTab.list_of (Conjdb_CtxtInfo.lemmas_in_ctxt ctxt))
      in (proof_thm_opt, lemmas) end;

  (* induction and rippling tactic, for direct use in Isabelle. *)
  fun ripple_tac ctxt rtech th = 
      let 
        val conjecture = Logic.get_goal (Thm.prop_of th) 1;
        val g = "g"
        (* configure prover with dtype theorems *)
        val thms = ripple_thms_of_term ctxt conjecture;
  
        val prepared_ctxt = 
            ctxt |> Context.proof_map (WRulesGCtxt.init NONE)
                 |> fold (Context.proof_map o WRulesGCtxt.add_wrule_thm) thms
  
        val (init_goal,pp) = PPlan.conj_term_at_top (g,conjecture) (PPlan.init prepared_ctxt)
    in
      (RState.init_from_pp pp)
        |> RState.set_goalnames [init_goal]
        |> RState.set_rtechn (SOME rtech)
        |> GSearch.depth_fs (fn rst => is_none (RState.get_rtechn rst) 
                             andalso RstPP.solved_all_chk rst) RState.unfold
        |> Seq.map (fn rst => RstPP.result_thm rst g)
        |> Seq.map (fn th2 => th2 RS th) (* apply resulting theorem *)
    end;
  
  (* Make rippling Isar method *)
  fun ripple_meth ctxt = 
      Method.METHOD (K (ripple_tac ctxt (RTechnEnv.map_then RippleLemCalc.induct_ripple_lemcalc)));
  val ripple_meth_text = Method.Basic ripple_meth;
  
(* 
  fun induct_auto_meth ctxt = SIMPLE_METHOD (DB_InductiveTacs4.bef_induct_auto_tac 
      (Unsynchronized.ref TSet.empty) ctxt);
  val induct_auto_meth_text = Method.Basic (induct_auto_meth);
*)

end;

structure TM_Provers : TM_PROVERS = DB_TM_Provers

