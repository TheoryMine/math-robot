theory example_To_add
imports tm_datatypes
begin

-- "Type: To := C_ad (To, B) | C_ac (N)"

term "C_ac" 
term "C_ad"

-- "define an additon like function"

ML {*
val t1 = @{term "Trueprop (f (C_ac n) (y :: To) = y)"};
val t2 = @{term "Trueprop (f (C_ad x b) (y :: To) = C_ad (f x y) b)"};
val rec_ty_name = "To";
val funtion_name = "f";
*}
setup {* MakeFun.add_new_function [t1,t2] *}
print_theorems

-- "Setup synthesis"
lemmas rules = f_a.simps
lemmas wrules[wrule] = rules 
ML {*
  (* set constraint params *)
  val cparams = 
      ConstraintParams.empty 
        |> ThyConstraintParams.add_eq @{context}
        |> ((ConstraintParams.add_consts o map Term.dest_Const)
            [@{term "f_a"}])
        |> ConstraintParams.add_thms @{context} @{thms "rules"}
        |> ThyConstraintParams.add_datatype @{context} "tm_datatypes.To";

  ConstraintParams.print @{context} cparams;
*}

-- "Synthesise equality conjectures"
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
       (3,12) (* min and max size of synthesised terms *)
       3 (* max vars *)
       @{theory} (* initial theory *)
       thy_constraints (* initial theory constraints *) )
       ;
*}

-- "Print synthesised conjectures"
ML{*
  val _ = map (Trm.print @{context} o fst) thms;
  Pretty.writeln (Pretty.str "---");
  val _ = map (Trm.print @{context} o fst) conjs;
*}

 



end;
