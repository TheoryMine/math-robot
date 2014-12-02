val name_variables = ["a","b","c","d","e","f","g","e","f","g","h","i","l","m","n"];

(* constructors_names has always the recursive type on 1st position by default. do not change it *)
val constructors_names = ["null", "C0", "C1", "C2", "C3", "C4","C5", "C6", "C7","C8", "C9" ];
val null_constructor = ((List.hd  constructors_names), []);
val name_extra_terms = ["T1","T2","T3","T4","T5","T6","T7"];

val plus = Const("HOL.plus_class.plus", Type("fun", [Type("nat", []), Type("fun", [Type("nat", []), Type("nat", [])])]));
val times = Const("HOL.times_class.times", Type("fun", [Type("nat", []), Type("fun", [Type("nat", []), Type("nat", [])])]));
(**) val name_data = "MyMain.dataType_b";

val zer_fun =  (Const("HOL.zero_class.zero", Type("nat",[])));
val one_fun =  (Const("HOL.one_class.one", Type("nat",[]))) ;
val null_fun = (Free("null", Type( name_data,[]))) ;


(**) val name_funs = ["FUN1","FUN2", "FUN3", "FUN4"];
(**) val all_name_funs = ["FUN1","FUN2", "FUN3", "FUN4"];


(**) val unit =  (Free("null",Type(name_data,[])));
val type_extra_terms =   [Type("nat",[]), Type("nat",[]),Type("nat",[]), Type("nat",[]) ];


val availble_functions = [ Const("HOL.plus_class.plus", Type("fun", [Type("nat", []), Type("fun", [Type("nat", []), Type("nat", [])])])),Const("HOL.times_class.times", Type("fun", [Type("nat", []), Type("fun", [Type("nat", []), Type("nat", [])])]))];



(*val dumb_fun = (Free("DUMBDUMB", Type("fun", [Type("TRYTRY", []), Type("fun", [Type("nat", []), Type("nat", [])])])));*)


(**) val initial_functions =  zer_fun :: one_fun :: availble_functions;  (*null_fun :: zer_fun :: one_fun :: availble_functions;*)


(*val dumb_funcs = dumb_fun::initial_functions;*)
(*val made_up_fun = Free("made_up_fun", Type("fun", [Type(name_data, []), Type("fun", [Type("nat", []), Type("nat", [])])]));*)

(**)val choosen_funcs = ([0,9,7,4],[0,2,5,3],[9,1,3,11]);

(*avaible_types has always the recursive type on 1st position by default. do not change it *)

(**)val list_avaible_types = [name_data,"nat"];
(**)val non_rec_typ = tl  list_avaible_types;

(*val aaa = create_theory a_data 2 (1,1,0) choosen_funcs  initial_functions; 
val bbb = Free ("FUN1", Type("fun", [Type("MyMain.dataType_b", []), Type("nat", [])]));
fun is_arity_1 x = x= bbb;
val zzz = (map  (hd) (map tl (List.nth(aaa,1))));
 map (exists_subterm  is_arity_1) zzz;
*)
