theory dbg
imports tm_functions
begin

ML {* TM_Data.DType.Ctxt.print_dtyp @{context} (Tn.mk "T_1");
@{cpat "HOL.eq :: ?'a => ?'a => HOL.bool"}
*}
ML {*
 val simp_thms = the (#simps (Function.get_info @{context} @{term "f_1"}));
*}
term "f_1"
term "C_1"
term "C_2"

ML{*
val thy = @{theory};
val ctxt = ProofContext.init_global thy;
val n = (Fn.mk "f_1");

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
      val _ = Constraints.print ctxt thy_constraints;

      val top_term = Thm.term_of @{cpat "HOL.eq :: ?'a => ?'a => HOL.bool"};
      val top_const = (Constant.mk (fst (Term.dest_Const top_term)));

      val prepared_thy = (* prepare the proof tool(s) *)
          thy |> Context.theory_map (WRulesGCtxt.init NONE)
              |> fold (Context.theory_map o WRulesGCtxt.add_wrule_thm) thms ;

*}

-- "Synthesise equality conjectures"
ML {*
val ((thy_constraints',thy'),(conjs,thms)) = ConstrSynthesis.synthesise_terms
       top_const (* top constant *)
       ConstrSynthesis.VarAllowed.is_hole_in_lhs (* where are free vars allowed *)
       (4,12) (* min and max size of synthesised terms *)
       ((length (fst (Term.strip_type fty))) + 1) (* max vars = nargs + 1 *)
       prepared_thy (* initial theory *)
       thy_constraints (* initial theory constraints *)
*}
ML{*
 val _ = map (Trm.print @{context} o fst) thms;
  Pretty.writeln (Pretty.str "---");
  val _ = map (Trm.print @{context} o fst) conjs;
*}

(* the above should, at least, find this ... it does, that's nice. *)
theorem "f_1 x y = y" apply (induct "x") apply auto; done


end;
