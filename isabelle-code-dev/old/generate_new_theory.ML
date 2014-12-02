
(* which function are picked from the lists;
 if  number_of_functions = (1,2,1); and  choosen_funcs = ([0,6,7,4],[0,2,5,3],[9,1,3,11])]; then it inserts
arity 1 = 0th function
arity 2 = 0th and 2nd function
arity 3 = 9th function
 Note that this must be changed with search method*)

val choosen_funcs = ([0,9,7,4],[0,2,5,3],[0,1,3,11]);


(* given the lhs and the rhs of a function for a constructor, it builds it as sound term for Isabelle*)

fun make_a_constr_equation lhs rhs = 
    let 
      val typ = Term.type_of rhs;
    in 
      Const("Trueprop", Type("fun", [Type("bool", []), Type("prop", [])])) $
           ((Const("op =", Type("fun", [ty, Type("fun", [ty, Type("bool", [])])]))) $ lhs $ rhs)
    end;

(* given a list of lhs and a list of rhs for a data type it returns a list of functions as sound terms for Isabelle*)

exception list_of_rhs_and_lhs_not_same_length
fun make_a_data_equation [] [] = []
  | make_a_data_equation [] _ = raise list_of_rhs_and_lhs_not_same_length
  | make_a_data_equation _ [] =  raise list_of_rhs_and_lhs_not_same_length
  | make_a_data_equation (lhs::lhs_list) (rhs:: rhs_list) = 
             (make_a_constr_equation lhs rhs) ::
              make_a_data_equation lhs_list  rhs_list;
     


(* this given a function name and its returning type and a list on initial functions adds this function to the initial functions. 
TRY ON -> extend_initial_functions "FUN" availble_functions 2 (Type("nat",[])); *)


fun extend_initial_functions  name_fun list_initial_funcs
                              arity_fun_to_add type_func_to_add= 
     let 
      val type_extra_terms = List.take(
                               (Tr.NTab.values extra_terms_table) , 
                               arity_fun_to_add  -1);
      val type_func_arguments =   (Tr.NTab.values extra_terms_table) @
                                  [Type (name_data ,[])]  ;
       val func_to_add = 
           Free(name_fun,type_func_arguments ---> type_func_to_add);
     in func_to_add :: list_initial_funcs
     end;



(* given a triple of number of functions for each arity to be created,and what number of function has to be interted (1st,2nd,3rd,4th) it returns the arity the next function must have
TRY ON ->  map (pick_next 1)  artity_3_theories;*)


exception trying_to_pick_next_atity_from_all_zeros
exception trying_to_pick_next_greater_than_4
fun pick_next 1 (0,0,0) = raise trying_to_pick_next_atity_from_all_zeros
  | pick_next 1 (0,0,_) = 3
  | pick_next 1 (0,_,_) = 2
  | pick_next 1 (_,_,_) = 1
  | pick_next 2 (0,0,0) = raise trying_to_pick_next_atity_from_all_zeros
  | pick_next 2 (_,0,0) = 1
  | pick_next 2 (_,0,_) = 3
  | pick_next 2 (_,_,_) = 2
  | pick_next 0 (0,0,0) = raise trying_to_pick_next_atity_from_all_zeros
  | pick_next 0 (0,_,0) = 2
  | pick_next 0 (_,_,0) = 1
  | pick_next 0 (_,_,_) = 3
  | pick_next 4 triple = pick_next 1 triple
  | pick_next _ _ = raise trying_to_pick_next_greater_than_4;


(* taken a triple of functions per arity, and the arity of the function we are adding, return a triple of functions per arity that still have to be added *)

exception update_arity_triples_on_unexisting_arity
fun update_arity_triples (a1,a2,a3) 1 = (a1 - 1,a2,a3)
   | update_arity_triples (a1,a2,a3) 2 = (a1,a2 - 1,a3)
   | update_arity_triples (a1,a2,a3) 3 = (a1,a2,a3 - 1)
   | update_arity_triples (a1,a2,a3) _ =
        raise update_arity_triples_on_unexisting_arity ; 

(*
picks which functions to insert in a theory
if  number_of_functions = (1,2,1); and  choosen_funcs =[(0,6,7,4),(0,2,5,3),(9,1,3,11) ; then it inserts
arity 1 = 0th function
arity 2 = 0th and 2nd function
arity 3 = 9th function

TRY ON->   val which_fun_number =
              pick_chosen_fun 2  (0,1,1) choosen_funcs;
*)

exception trying_to_pick_function_whith_invalid_arity
fun pick_chosen_fun 1 (a1,a2,a3) (chosen1,chosen2,chosen3)= List.nth(chosen1,a1-1)
   |pick_chosen_fun 2 (a1,a2,a3) (chosen1,chosen2,chosen3)= List.nth(chosen2,a2-1)
   |pick_chosen_fun 3 (a1,a2,a3) (chosen1,chosen2,chosen3)= List.nth(chosen3,a3-1)
   |pick_chosen_fun _ _ _ = raise trying_to_pick_function_whith_invalid_arity;



(*according to returning type of rhs, pick the right lhs for te function
NOTE: no exception, could not see an error in case type is not valid 
TRY ON -> *)

fun pick_right_lhs typ lhs_list = 
          let 
             val term_typ_list = map TheoryEdit.make_term_type
                                     (map Dn.dest (Dn.NSet.list_of data_names));
             val position = element_at_position typ term_typ_list;
           in List.nth(lhs_list, position )
           end;


exception picked_funxtion_to_big;
fun create_theory data number_of_functions (0,0,0) which_functions initial_funcs
                = []
   | create_theory data number_of_functions (a1,a2,a3) 
                   which_functions initial_funcs = 
     let 
       val number_funs_to_add = a1 + a2 + a3;
       val pick_position = mod((number_of_functions - number_funs_to_add + 1),3);
       val this_arity = pick_next pick_position (a1,a2,a3) ;
       val next_arity_triple = update_arity_triples (a1,a2,a3) this_arity;
       val fun_name = List.nth((map Fn.dest (Fn.NSet.list_of functions_names)),
                               (number_of_functions - number_funs_to_add));
       val rhs_list_of_lists = create_rhs fun_name initial_funcs data this_arity;  
       val rhs_list = merge_list_of_lists2 rhs_list_of_lists;
       val which_fun_number =
              pick_chosen_fun this_arity  (a1,a2,a3) choosen_funcs;
       val is_not_ok =  which_fun_number >= (length rhs_list) 
       fun is_ok is_not_ok = if is_not_ok then raise picked_funxtion_to_big else true;
       val is_ok = is_ok is_not_ok;
       val this_rhs = List.nth( rhs_list,which_fun_number );
       val type_rhs = Term.type_of (hd this_rhs);
       val lhs_list = make_lhs_a data this_arity 
                                  fun_name 
                              (map Cn.dest (Cn.NSet.list_of con_names));
       val this_lhs = pick_right_lhs type_rhs lhs_list;
       val this_function = make_a_data_equation this_lhs this_rhs;
       val update_initial_funs = extend_initial_functions fun_name
                                  initial_funcs this_arity type_rhs;
   in 
     ( update_initial_funs, this_function)(*rhs_list*) :: 
       (create_theory  data number_of_functions next_arity_triple 
                       which_functions  update_initial_funs )
   end;


(* takes a data and a tripple of how_many funtions for arity and return the data nad functions. try on 

TRY ON--> create_theory_2 a_data  (1,2,1);
create_theory_2 eg_data (2,2,0); *)

fun  create_theory_2  data (a1,a2,a3) =
     let 
     val all_funcs = create_theory
                       data (a1 + a2 + a3) (a1,a2,a3)
                       choosen_funcs  initial_functions; 
     val functions = map snd all_funcs;
     val initial_funcs = map fst all_funcs;
     in (data, functions, List.last initial_funcs)
     end;


(* this updates the initial terms where we want to consirder the existence of an already known theory when creating a new theory.
TRY ON -->
val fisrt_theory = create_theory_2 a_data (2,1,0);

val ( unit, name_data, initial_functions,  list_avaible_types,non_rec_typ, choosen_funcs) =
update_variables_with_new_theory ([0,1,2,3],[0,1,2,3],[0,1,2,3]) "MyMain.SECOND_DATA"  fisrt_theory;
val a_data2 =  convert_data_to_start ( List.nth((data_type 2 2),0));*)

(*
fun update_variables_with_new_theory  new_chosen_fun new_name_data new_function_names (data, functions,  initial_funcs) =
    let 
      val name_data = new_name_data;
      val list_avaible_types = name_data ::  list_avaible_types;
      val non_rec_typ = tl  list_avaible_types; 
      val  all_name_funs = new_function_names @ name_funs;
      val name_funs = new_function_names;
      val initial_functions =  initial_funcs;
      val choosen_funcs = new_chosen_fun;
      val unit =  (Free("null",Type(name_data,[])));
    in ( unit, name_data,name_funs, all_name_funs, initial_functions , list_avaible_types,non_rec_typ, choosen_funcs)
    end;
*)

(*
fun create_theory data number_of_functions (0,0,0) which_functions initial_funcs
                = []
   | create_theory data number_of_functions (a1,a2,a3) 
                   which_functions initial_funcs = 
     let 
       val number_funs_to_add = a1 + a2 + a3;
       val pick_position = mod((number_of_functions - number_funs_to_add + 1),3);
       val this_arity = pick_next pick_position (a1,a2,a3) ;
       val next_arity_triple = update_arity_triples (a1,a2,a3) this_arity;
       val fun_name = List.nth(name_funs, 
                               (number_of_functions - number_funs_to_add));
       val rhs_tuples = create_rhs fun_name initial_funcs data this_arity;  
       val rhs_list = (fst  rhs_tuples) @ (snd rhs_tuples);
       val which_fun_number =
              pick_chosen_fun this_arity  (a1,a2,a3) choosen_funcs;
       val this_rhs = List.nth( rhs_list,which_fun_number );
       val type_rhs = Term.type_of (hd this_rhs);
       val lhs_tuple = make_lhs_a data this_arity 
                                  fun_name constructors_names;
       val this_lhs = pick_right_lhs type_rhs lhs_tuple;
       val this_function = make_a_data_equation this_rhs this_lhs;
       val update_initial_funs = extend_initial_functions fun_name
                                  initial_funcs this_arity type_rhs
   in 
       rhs_list :: 
       (create_theory  data number_of_functions next_arity_triple 
                       which_functions  update_initial_funs )
   end;
*)


