




(* says in which position is an element in a list
TRY ON -->  element_at_position 3 [1,2,3,4];
*)
exception element_not_in_list
fun element_at_position elem list = 
    let
      fun element_at_position2 _ [] _ = raise element_not_in_list
        | element_at_position2 a (h::t) n =
               if a = h then (n - (length t) -1)
               else element_at_position2 a t n;
     in element_at_position2 elem list (length list) end;

fun is_right_order a b list = 
     (element_at_position a list) <= (element_at_position b list);

fun create_tuples  [] _  = []
   | create_tuples (h::t) elem   = ( h @ elem) 
                                      ::  (create_tuples  t elem );

fun create_tuples_2  [] _ _  = []
   | create_tuples_2 (h::t) elem initial_list  = 
                      if is_right_order  [List.last h] 
                              [hd elem] initial_list
                         then ( h @ elem) 
                              ::  (create_tuples_2  t elem initial_list)
                      else  (create_tuples_2  t elem initial_list);

fun list_of_tuples [] [] = []
  | list_of_tuples [] _ = []
  | list_of_tuples _ []  = []
  | list_of_tuples (h1::t1) (h2::t2) = (h1,h2):: (list_of_tuples t1 t2);

fun cross_prod _ [] = []
   | cross_prod  list (h::t) = (create_tuples  list  h) @
                                 ( cross_prod  list t);


fun cross_prod_2 _ [] _= []
   | cross_prod_2 [] _ _=  []
   | cross_prod_2  list (h::t) initial_list= 
          (create_tuples_2  list  h initial_list) @
                       ( cross_prod_2 list t initial_list);


fun list_of_list [] = []
   | list_of_list (h::t) = [h]:: (list_of_list  t);


 fun  && true true = true
  |  && true false = false 
  |  && false true = false
  |  && false false = false;


 fun || true true = true
  |  || true false =  true
  |  ||  false true = true
  |  || false false = false;


fun my_member _ [] = false
   | my_member a (h::t) = if a = h then true else my_member a t;




fun eliminate_double [] = []
| eliminate_double (h::t) = if my_member h t then  eliminate_double t
else h :: (eliminate_double t);

fun return_double [] = []
| return_double (h::t) = if my_member h t then  h :: (return_double t)
else  (return_double t);


exception merge_list_of_lists_fails
fun merge_list_of_lists [] = []
   | merge_list_of_lists ([h]::t) = h ::  (merge_list_of_lists t)
   |  merge_list_of_lists (_::t) = raise  merge_list_of_lists_fails;


fun merge_list_of_lists2 [] = []
   | merge_list_of_lists2 (h::t) = h @  (merge_list_of_lists2 t);

fun create_tuples  [] _  = []
   | create_tuples (h::t) elem   = ( h @ elem) 
                                      ::  (create_tuples  t elem );

fun cross_prod _ [] = []
   | cross_prod  list (h::t) = (create_tuples  list  h) @
                                 ( cross_prod  list t);

fun list_of_list [] = []
   | list_of_list (h::t) = [h]:: (list_of_list  t);

fun cross_prod_list [] = []
   | cross_prod_list list = 
              if (length list = 1) then hd list
              else cross_prod (hd list) (cross_prod_list (tl list));


(* 
exception costr_names_too_little;
fun make_tuples_costr_name _ [] = []
                 |  make_tuples_costr_name [] _ = 
                          raise costr_names_too_little
                 |  make_tuples_costr_name (name::names) (const::consts) = 
                              if const = [Free("null",  Type(name_data,[]))]
                                            then 
                                               (make_tuples_costr_name (name::names) consts)
                               else
                               (name,const) :: 
                                            (make_tuples_costr_name names consts);
*)

fun substitute_in_list_pos pos elem list= List.take(list, (pos)) @ [elem] @ List.drop(list,(pos+1));

fun substitute_in_list  _ _ [] = []
   |substitute_in_list  old_elem new_elem (h::t) =
          if h =  old_elem then new_elem :: (substitute_in_list  old_elem new_elem t)
          else h :: (substitute_in_list  old_elem new_elem t);


fun add_tuple_to_tuplt_list (first,second) (list_first,list_second) = 
      (first:: list_first,second :: list_second);

fun add_elem_to_list a [] = [a]
   |add_elem_to_list a list = a::list;

(*takes the last n  arguments of a list*)

fun get_arity_elem_from_list 0 list = []
  | get_arity_elem_from_list n list = List.drop(list, ((length list) - n));

fun find_fist_diff [] [] = []
  | find_fist_diff [] _ = []
  | find_fist_diff _ []  = []
  | find_fist_diff (h::t) (h2::t2)=
    if (h = h2)
       then find_fist_diff t t2
    else [h,h2];




fun make_list_of_empty_lists 0 = []
   | make_list_of_empty_lists n = [] :: (make_list_of_empty_lists (n-1));

exception can_not_distribute_elements_in_empty_list
fun distribute_elements_in_lists [] lists = lists
   | distribute_elements_in_lists elems [] = raise can_not_distribute_elements_in_empty_list
   | distribute_elements_in_lists (e::elems) (one_list:: rest) = 
                              (e::one_list) :: (distribute_elements_in_lists elems rest);

exception term_in_not_defined_form_in_name_of_term
fun name_of_term (Free(name, _)) = name
   | name_of_term (Const(name, _)) = name
   | name_of_term _  = raise term_in_not_defined_form_in_name_of_term;

fun head_name_of term =  name_of_term (Term.head_of term );
(* 
usefull function in term


val argument_type_of : Term.term -> int -> Term.typ
val could_unify : Term.term * Term.term -> bool (look at can be applied)

val equals : Term.typ -> Term.term

val head_name_of : Term.term -> string
val head_of : Term.term -> Term.term

val list_all : (string * Term.typ) list * Term.term -> Term.term

val size_of_term : Term.term -> int

val strip_all_body : Term.term -> Term.term
val strip_comb : Term.term -> Term.term * Term.term list




*)
