theory ExampleFuns
imports tm_datatypes
begin

ML {* 
(* all type name set of current context *)
val nset = (TM_Data.DType.Ctxt.get_tnset @{context});

(* type names we know we can recurse on because we constructed them *)
val rnset = TM_Data.DType.Ctxt.get_ctnset @{context}; 
val SOME rec_tynm1 = Tn.NSet.get_first rnset;
val SOME rec_tynm2 = Tn.NSet.next_bigger rnset rec_tynm1; (* next type name *)
val SOME rec_tynm3 = Tn.NSet.next_bigger rnset rec_tynm2; (* next type name *)
val rec_tynm = rec_tynm2;

val SOME non_rec_tynms1 = DataGen.nr_mk_bot_elem_list nset 3; (* other arguments used *)
val SOME non_rec_tynms2 = DataGen.nr_elem_list_suc' nset non_rec_tynms1; (* create next one... *)
val (result_tynm::arg_tynms) = map (fn DataGen.Typ x => x) non_rec_tynms1;

val funs = Fn.NTab.get_nameset (TM_Data.Fun.Ctxt.get_fntab @{context}); 
val n_funs = Fn.NSet.cardinality funs;

val eqf_name = Fn.mk (fst (Term.dest_Const @{term "op ="}));
(* *)

(* should be constructed from function symbols involved *)
val all_types = Tn.NSet.of_list ([rec_tynm] @ (result_tynm::arg_tynms));

val avail_funs = 
    Fn.NSet.of_list ((Seq.hd (DataGen.seq_of_choose_n_from_list (Int.min(4,n_funs)) 
                      (Fn.NSet.list_of funs))));

*}


-- "Setup constraints"
ML {*
  (* set constraint params *)
  val cparams = 
      ConstraintParams.empty 
        |> ThyConstraintParams.add_eq @{context}
     (*    |> ((ConstraintParams.add_consts o map Term.dest_Const)
            [@{term "f_a"}])
        |> ConstraintParams.add_thms @{context} @{thms "rules"}  *)
        |> ThyConstraintParams.add_datatype @{context} "tm_datatypes.To";

  ConstraintParams.print @{context} cparams;
*}

(* maybe provide some basic HOL functions, e.g.  
 @ [Fn.mk eq_fn,Fn.mk if_fn]
*)

ML {* 
val funparams = 
  TM_Data.FunParams {
    rec_tynm = rec_tynm, (* type this function is recursive on *)
    arg_tynms = arg_tynms, (* other arguments used *)
    result_tynm = result_tynm, (* result type *)
    cparams = cparams, (* basic constraints *)
    size = 12
  };

*}

ML{* 
  val fs = PolyML.exception_trace (fn () => TM_Data.synth_funs @{theory} funparams);
  val nfs = length fs;
*}


ML{* 
  Pretty.writeln 
  ( Pretty.chunks 
    (map (fn ((f,tn,ty),ts) => 
          Pretty.block [Pretty.str f, Pretty.str " := ", 
          Pretty.list "[" "]" (map (Trm.pretty @{context}) ts)])
      fs)
  );
*}


ML{* TM_Data.Fun.Ctxt.print @{context}; *}

setup {* fold TM_Data.add_new_function' (Library.take 10 fs) *}
print_theorems

ML{* TM_Data.Fun.Ctxt.print @{context}; *}

end;
