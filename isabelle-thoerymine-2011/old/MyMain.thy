header{* Main + IsaP *}
theory MyMain
imports Main IsaP
begin

lemmas extra_wrule[wrule] = add_0 add_Suc add_0_right add_Suc_right
  mult_0 mult_Suc mult_0_right mult_Suc_right add_mult_distrib
  nat_add_assoc nat_add_left_cancel nat_add_right_cancel 
  nat_mult_assoc
  add_mult_distrib2 Suc_mult_cancel1;


(*
ML {* 
  map (fn x => x + 1) [1,2,3] @ [100];
*} *)

ML {*
(* constructor names *)
structure Cn :> SSTR_NAMES = 
  struct open SStrName; val default_name = mk "Ca"; end;

(* type names: elements/arguments in a constructor *)
structure Dn :> SSTR_NAMES = 
  struct open SStrName; val default_name = mk "Ta"; end;

(* names for variables *)
structure Vr :> SSTR_NAMES = 
  struct open SStrName; val default_name = mk "x_a"; end;

(* ??? not sure what these are for... ? *)
(* names for extra terms *)
structure Tr :> SSTR_NAMES = SStrName;

(* names for function symbols *)
structure Fn :> SSTR_NAMES = SStrName;
*}


ML {*
(*use "list_of_var";*)
use "help_functions";
*}



ML {*
use "theory_edit";
*}




ML{*  (* Initial background configuration *)

val bool_dn = Dn.mk "bool"
val bool_ctab = 
  Cn.NTab.empty 
    |> Cn.NTab.update (Cn.mk "True",[] : TheoryEdit.elem_type list)
    |> Cn.NTab.update (Cn.mk "False",[]);

val nat_dn = Dn.mk "nat";
val nat_ctab = 
  Cn.NTab.empty 
    |> Cn.NTab.update (Cn.mk "Suc",[TheoryEdit.Rec])
    |> Cn.NTab.update (Cn.mk "0",[]);

val init_dthy = 
  Dn.NTab.empty 
    |> Dn.NTab.update (bool_dn, bool_ctab)
    |> Dn.NTab.update (nat_dn, nat_ctab)

val init_data_names = Dn.NTab.get_nameset init_dthy;

val print_dthy =
  Dn.NTab.print 
    (fn cntab =>
      Pretty.block 
        [Pretty.str "{",
         Cn.NTab.pretty (Pretty.list "[" "]" o map TheoryEdit.pretty_elem_typ) cntab,
         Pretty.str "}"])

(* 
Dn.NSet.of_list (map Dn.mk ["bool","nat"]);
*)

*}



ML{*
(*playing  bit with theory_edit *)
(*print_depth 300;
init_data_names;
cross_prod_2 [[1],[2,3],[4]] [[1],[2,3],[4]];
val try = TheoryEdit.create_rec_length_constructors init_data_names 4;
(*TheoryEdit.create_constructors init_data_names 4;*)
 TheoryEdit.create_rec_constructors init_data_names 3;
 TheoryEdit.create_all_constructors init_data_names 3;
 TheoryEdit.create_data_type init_data_names  {nconstr = 2, nelems = 3};
 val rec_cost = list_of_list( TheoryEdit.create_rec_constructors init_data_names 3 );
val rec_costr_length = filter (fn a => length (hd a) = 3 ) rec_cost;
  val rec_costr_not_length = filter (fn a => not (length (hd a) = 3) ) rec_cost;
val aaa =  TheoryEdit.create_data_type init_data_names {nelems = 2, nconstr = 4};
length aaa;
val aaa =  eliminate_double aaa;
length aaa;*)
*}



ML {*
(Pretty.list "[" "]" o map TheoryEdit.pretty_elem_typ)
*}

ML {* 
  Dn.NSet.print init_data_names;
  print_dthy init_dthy;
*}


(* create datatypes upto size 3 *)

ML {* 
  val dthy2 = TheoryEdit.mk_isa_datatype {nconstr = 3, nelems = 3} init_dthy;
  print_dthy dthy2;
*}





ML {*
(*val list_names = StrName.NSet.empty;
val (new_name, names) = StrName.NSet.add_new "dataType" list_names;
val (new_name2, names2) = StrName.NSet.add_new "dataType" names;
val (new_name3, names3) = StrName.NSet.add_new "dataType" names2;
*)
*}


ML{*
structure Try :> TERM = Term;
structure foo = struct open Try; end;

val eg_terms = [(Free("a", Type("Rec",[]))),(Free("b", Type("nat",[]))),(Free("c", Type("nat",[])))];
val eg_terms2 = [(Free("a", Type("nat",[]))),(Free("b", Type("nat",[]))),(Free("c", Type("nat",[])))]
val con_fun = Term.betapplys ((Const("C0", Type("fun", [Type("Rec", []),  Type("fun", [Type("nat", []), Type("fun", [Type("nat", []),Type("Rec", [])])])]))) ,eg_terms) ;

Term.add_free_names con_fun [];

(*map TheoryEdit.make_term_type (map Dn.dest (Dn.NSet.list_of data_names))*)

*}

ML{*
use "make_rhs";
*}


ML{*

(*examples playing with make_rhs*)

val eg_terms = [(Free("a", Type("Rec",[]))),(Free("b", Type("nat",[]))),(Free("c", Type("nat",[])))];
val eg_terms2 = [(Free("a", Type("nat",[]))),(Free("b", Type("nat",[]))),(Free("c", Type("nat",[])))]
val con_fun = Term.betapplys ((Const("C0", Type("fun", [Type("Rec", []),  Type("fun", [Type("nat", []), Type("fun", [Type("nat", []),Type("Rec", [])])])]))) ,eg_terms) ;
Term.head_of con_fun;

name_of_term (Term.head_of con_fun);
units_list;

(*structure Try :> TERM = Term;
structure foo = struct open Try; end;*)

val eg_type2 = Type("fun",[Type("nat", []), Type("fun", [Type("nat", []), Type("fun", [Type("nat", []), Type("nat", [])])])]);
val eg_type3 = Type("fun",[Type("Rec", []), Type("fun", [Type("nat", []), Type("fun", [Type("nat", []), Type("nat", [])])])]);

my_convert_constr_to_start var_names eg_type3;
make_extra_terms 4  extra_terms_table;
initial_typ  "FUN" 2 extra_terms_table "TRYTRYTRY" eg_terms;
all_initial_data  "FUN" 2 extra_terms_table [eg_terms];
sub_hd_with_function plus eg_terms;
 can_be_applied plus eg_terms2;
apply_at_position 3 plus eg_terms2;
sub_fun_to_terms plus eg_terms2;
substitute_all_fun_all_terms [times,plus] [eg_terms2];
all_functions_for_constructor [times,plus,zero_fun,one_fun] eg_terms2;
partition_by_returning_type [times,plus] eg_terms2;
all_functions [eg_terms,eg_terms2] ([plus,times],(Type("nat",[])));
make_costr_fun ("C0", eg_terms);
create_rhs "FUN1"  initial_functions [eg_terms,eg_terms2] 2;

*}



ML{*
use "make_lhs";
*}

ML{*

(*examples playing with make_lhs *)
 (Tr.NTab.values extra_terms_table);
 (map Dn.dest (Dn.NSet.list_of data_names)) ;
make_lhs_a [eg_terms,eg_terms2] 2 "FUN1"
 (map Cn.dest (Cn.NSet.list_of con_names));



*}


ML{*
use "generate_new_theory";
*}

ML{*

create_theory_2 [eg_terms,eg_terms2] (1,0,0);

*} 
ML {* 
(* looks inside Dn structure; *)
structure foo = struct open Dn; end;
(*  can also see source code: 
/afs/inf.ed.ac.uk/group/dreamers/public/software/Isa2009-1/IsaP-trunk/isaplib/names/
see: basic_nameset.ML, basic_nametab.ML, names.ML
*)
*}


ML {* Constr.NTab.empty *}
ML {* fold *}


end;