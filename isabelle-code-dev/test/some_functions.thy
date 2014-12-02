theory ExampleFuns
imports tm_datatypes
begin

-- "add equality to collection of known (isabelle) functions" 
ML {* 
val (if_then_else_c as (if_fn,_)) = Term.dest_Const (Term.head_of @{term "if x then y else z"});
val eqf_c as (eq_fn,_) = Term.dest_Const @{term "op ="};
*}
setup {* MakeFun.add_isabelle_function (eqf_c,[]) *}
setup {* MakeFun.add_isabelle_function (if_then_else_c,[]) *}

(* Example *)
-- "Define the material world functon"
ML {*
val t1 = @{term "Trueprop (mwf (C_a b1 b2) (y :: MW) = y)"};
val t2 = @{term "Trueprop (mwf (C_b x) (y :: MW) = C_b (mwf x y))"};
val rec_ty_name = "MW";
val funtion_name = "mwf";
*}
-- "Example use: add material world function to theory; NOTE: function named f_a"
setup {* MakeFun.add_new_function [t1,t2] *}
print_theorems

-- "Prove some stuff"
lemmas f_a.simps[wrule]
theorem left_commute_of_f_a[wrule]: "f_a (f_a x y) z = f_a (f_a y x) z"
apply (rippling)
done
theorem assoc_of_f_a[wrule]: "f_a (f_a x y) z = f_a x (f_a y z)"
apply (rippling)
done

-- "define the guardian extension"
ML {*
val t1 = @{term "Trueprop (f_b (C_a b1 b2) (y :: MW) = C_a b1 b2)"};
val t2 = @{term "Trueprop (f_b (C_b x) (y :: MW) = f_a y (f_b x y))"};
val rec_ty_name = "MW";
val funtion_name = "f_b";
*}

setup {* MakeFun.add_new_function [t1,t2] *}
print_theorems

lemmas f_b.simps[wrule]

theorem distr_of_f_b_over_fa[wrule]: "f_b (f_a y k) z = f_a (f_b y z) (f_b k z)"
apply (rippling)
done

theorem assoc_of_f_b[wrule]: "f_b (f_b x y) z = f_b x (f_b y z)"
apply (rippling)
done

theorem AnneGlover_unit2[wrule]: "f_b a (C_b (C_a b c)) = a"
apply rippling
done

theorem mw_thm2[wrule]: "f_a a (C_b b) = C_b (f_a a b)"
by rippling

theorem "f_a (f_b x (C_a y z)) x = x"
by rippling (* uses: mw_thm2 *)

theorem "f_b (C_b (C_a y z)) x = x"
oops 

lemmas rules = f_b.simps f_a.simps

lemmas rules2 = assoc_of_f_b distr_of_f_b_over_fa;

lemmas wrules[wrule] = rules 

ML {*
  (* set constraint params *)
  val cparams = 
      ConstraintParams.empty 
        |> ThyConstraintParams.add_eq @{context}
        |> ((ConstraintParams.add_consts o map Term.dest_Const)
            [@{term "f_a"},
             @{term "f_b"}])
        |> ConstraintParams.add_thms @{context} @{thms "rules"}
        |> ThyConstraintParams.add_datatype @{context} "ExampleData.MW";

  ConstraintParams.print @{context} cparams;
*}

ML {*
val thy_constraints = (Constraints.init @{context} cparams);
Constraints.print @{context} thy_constraints;
val top_term = Thm.term_of @{cpat "op = :: ?'a => ?'a => bool"};
val top_const = (Constant.mk (fst (Term.dest_Const top_term)));
*}
 
ML{*
val ((thy_constraints',thy'), (* updated constraints and theory *) 
     (conjs,thms))
    = PolyML.exception_trace (fn () => 
    ConstrSynthesis.synthesise_terms 
       top_const (* top constant *)
       ConstrSynthesis.VarAllowed.is_hole_in_lhs (* where are free vars allowed *)
   (*     ConstrSynthesis.VarAllowed.always_yes  *)
       (3,9) (* min and max size of synthesised terms *)
       3 (* max vars *)
       @{theory} (* initial theory *)
       thy_constraints (* initial theory constraints *) )
       ;
*}


ML{*
  val _ = map (Trm.print @{context} o fst) thms;
  Pretty.writeln (Pretty.str "---");
  val _ = map (Trm.print @{context} o fst) conjs;
*}

 


.
ML {*
(* val i = Function.get_info @{context} @{term "f_a"}; 
NOTE: doesn't work for: plus_nat, because it was defined with primrec
*)
*}

-- "Should we filter instances of common types, e.g. list of bools:"
ML {* MakeData.Ctxt.print_dtyp @{context} (Tn.mk "T_3"); *}

-- "Some extra constructors in front of B and N"
ML {* MakeData.Ctxt.print_dtyp @{context} (Tn.mk "T_1"); *}
ML {* MakeData.Ctxt.print_dtyp @{context} (Tn.mk "T_2"); *}

ML {* 
fun add_constrs types = 
    Tn.NSet.fold (fn n => case (FnTnMap.lookup_codf (MakeData.Thy.get_ctmap @{theory}) n)
                        of NONE => I | SOME cnset => Fn.NSet.union_merge cnset)
                 types;
*}

ML {* 
(* all type name set of current context *)
val nset = (MakeData.Ctxt.get_tnset @{context});

(* type names we know we can recurse on because we constructed them *)
val rnset = MakeData.Ctxt.get_ctnset @{context}; 
val SOME rec_tynm1 = Tn.NSet.get_first rnset;
val SOME rec_tynm2 = Tn.NSet.next_bigger rnset rec_tynm1; (* next type name *)
val SOME rec_tynm3 = Tn.NSet.next_bigger rnset rec_tynm2; (* next type name *)
val rec_tynm = rec_tynm2;

val SOME non_rec_tynms1 = DataGen.nr_mk_bot_elem_list nset 3; (* other arguments used *)
val SOME non_rec_tynms2 = DataGen.nr_elem_list_suc' nset non_rec_tynms1; (* create next one... *)
val (result_tynm::arg_tynms) = map (fn DataGen.Typ x => x) non_rec_tynms1;

val funs = Fn.NTab.get_nameset (MakeFun.Ctxt.get_fntab @{context}); 
val n_funs = Fn.NSet.cardinality funs;

val eqf_name = Fn.mk (fst (Term.dest_Const @{term "op ="}));
(* *)

(* should be constructed from function symbols involved *)
val all_types = Tn.NSet.of_list ([rec_tynm] @ (result_tynm::arg_tynms));

val avail_funs = 
    Fn.NSet.of_list ((Seq.hd (DataGen.seq_of_choose_n_from_list (Int.min(4,n_funs)) 
                      (Fn.NSet.list_of funs))) @ [Fn.mk eq_fn,Fn.mk if_fn]);

val funparams = 
  MakeFun.FunParams {
    rec_tynm = rec_tynm,
    arg_tynms = arg_tynms, 
    result_tynm = result_tynm,
    avail_funs = avail_funs,
    all_types = all_types,
    thrms = [],
    size = 8
  };

*}

ML{* 
  val fs = PolyML.exception_trace (fn () => MakeFun.synth_funs funparams) @{theory};
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


ML{* MakeFun.Ctxt.print @{context}; *}

setup {* fold MakeFun.add_new_function' (Library.take 5 fs) *}
print_theorems

ML{* MakeFun.Ctxt.print @{context}; *}

ML{* MakeFun.Ctxt.print @{context}; *}
ML{* MakeFun.Ctxt.print @{context}; *}
ML{* MakeFun.Ctxt.print @{context}; *}
ML{* MakeFun.Ctxt.print @{context}; *}
ML{* 
val constInfoTab = 
        ConstInfo.init_const_infos_for_just 
          avail_funs (* function-names, types and def-eqs, to use by synthesis *)
          all_types  (* datatype names to use in synthesis (automatically adds constructors) *)
          (get_constr_thrms funparams)  (* additional theorems to generate constraints from*)
          @{theory};
*}


.

setup {* MakeFun.synth_and_add_funs funparams *}

print_theorems

ML{*
  MakeFun.print @{context} (MakeFun.of_thy thy');
*}

.


ML {*
local open MakeFun in
val thy = @{theory};
val _ = print @{context} (of_thy thy);
end;
*}


ML {*
local open MakeFun in
val thy = @{theory};

    val default_funnm = "_f"; 

    (* theory/global data *)
    val type_data = MakeData.ThyData.get thy;
    val types_tab = MakeData.get_typs type_data; (* Datatype data *)
    val data = ThyData.get thy; (* Function data *)

    val (rec_tyname, rec_typ) = Tn.NTab.get types_tab (get_rec_tynm funparams); 
    val other_args = map (snd o Tn.NTab.get types_tab) (get_arg_tynms funparams);
    val (result_tyname,result_type) = Tn.NTab.get types_tab (get_result_tynm funparams);
    val all_types = map (snd o Tn.NTab.get types_tab) 
                        (Tn.NSet.list_of (get_all_types funparams));
    val MakeData.Ndtyp ndtab = MakeData.get_dtyp type_data (get_rec_tynm funparams);
end;
*}

.


setup {* PolyML.exception_trace (fn () => ) *}
print_theorems;

.

ML {* 
(* make first non-recursive list of elements *)

(* all type name set of current context *)
val nset = (MakeData.tnset_of_ctxt @{context});

val SOME non_rec_tynms1 = DataGen.nr_mk_bot_elem_list nset 4; (* other arguments used *)
val SOME non_rec_tynms2 = DataGen.nr_elem_list_suc' nset non_rec_tynms1; (* create next one... *)

(* type names we know we can recurse on because we constructed them *)
val rnset = MakeData.ctnset_of_ctxt @{context}; 
val SOME rec_tynm1 = Tn.NSet.get_first rnset;
val SOME rec_tynm2 = Tn.NSet.next_bigger rnset rec_tynm1; (* next type name *)
val SOME rec_tynm3 = Tn.NSet.next_bigger rnset rec_tynm2; (* next type name *)

val avail_funs = Fn.NTab.get_nameset (MakeFun.fntab_of_ctxt @{context}); 
val no_avail_funs = Fn.NSet.cardinality avail_funs;

(* *)
val avail_funs = (Seq.hd (DataGen.seq_of_choose_n_from_list (Int.min(4,no_avail_funs)) 
                      (Fn.NSet.list_of avail_funs))) @ [];

(* should be constructed from function symbols involved *)
val all_types = Tn.NSet.of_list ([rec_tynm2] @ (map (fn DataGen.Typ x => x) non_rec_tynms2));

*}
;.;
ML {*
val rec_tn = 
val p = 
  FunParams {
    rec_tynm = rec_tynm,
    arg_tynms = non_rec_tynms, 
    res_tynm = Tn.name, (* result type *)
    avail_funs = Fn.NSet.T, (* Names of other funs that synthesis may use *)
    all_types = Tn.NSet.T, (* All types used in this synthesis attempt. Including
                              types used by the function we're synthesising, and
                              types used by any function in the avail_funs set. *)
    thrms = Thm.thm list, (* Theorems to generate constraints from, during fun synthesis.*)
    size = 14
  };

*}





-- "define the Glover's Function"
ML {*
val t1 = @{term "Trueprop (f_c (C_a b1 b2) (y :: MW) = y)"};
val t2 = @{term "Trueprop (f_c (C_b x) (y :: MW) = C_b (f_c x y))"};
val rec_ty_name = "MW";
val funtion_name = "f_c";
*}

setup {* MakeFun.add_new_function [t1,t2] *}
print_theorems

lemmas f_c.simps[wrule]

.

ML {*
val t1 = @{term "Trueprop (f_c (C_a b1 b2) (y :: MW) = C_a b1 b2)"};
val t2 = @{term "Trueprop (f_c (C_b x) (y :: MW) = f_b y (f_c x y))"};
val rec_ty_name = "MW";
val funtion_name = "f_c";
*}

setup {* MakeFun.add_new_function [t1,t2] *}
print_theorems

