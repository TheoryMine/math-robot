val unit=  (Free("null",Type(name_data,[])));
val one_fun = (Const("HOL.one_class.one", Type("nat",[])));
val zero_fun = (Const("HOL.zero_class.zero", Type("nat",[])));
val plus = Const("HOL.plus_class.plus", Type("fun", [Type("nat", []), Type("fun", [Type("nat", []), Type("nat", [])])]));
val times = Const("HOL.times_class.times", Type("fun", [Type("nat", []), Type("fun", [Type("nat", []), Type("nat", [])])]));
val initial_functions =[plus,times,zero_fun,one_fun];


fun make_unit typ=  (Free("null",Type(typ,[])));
(*val units_list = map make_unit (List.take (list_avaible_types, ((length list_avaible_types)-1)));*)

fun make_units_list typnames = map make_unit
                                   (map Dn.dest (Dn.NSet.list_of typnames));
val units_list =  make_units_list  data_names;

(*make a  list of all used type given a typr
TRY ON -> list_of_types eg_type3;*)

exception  list_of_type_on_unregular_type;
fun list_of_types  (Type (typ, []))= [typ]
   | list_of_types (Type (_, (h::t))) = (list_of_types h) @  (list_of_types (hd t))
   | list_of_types _ = raise list_of_type_on_unregular_type;

(*to try use on 
 my_convert_constr_to_start eg_type1; my_convert_constr_to_start eg_type2; *)
(*fun my_convert_constr_to_start typ = 
    let 
      val temp = list_of_types typ
      val list_of_constr_types= List.take(temp,((List.length temp) - 1 ));
      val var_and_type =  ListPair.zip(name_variables,list_of_constr_types);
      fun convert_tuple_to_start (name,a_typ) = 
          (Free(name , Type (a_typ,[])));
     in 
      map convert_tuple_to_start  var_and_type  end;*)

(*to try use on 
 my_convert_constr_to_start eg_type1; my_convert_constr_to_start  var_names  eg_type3; *)


fun my_convert_constr_to_start varset typ = 
    let 
      val temp = list_of_types typ
      val list_of_constr_types= List.take(temp,((List.length temp) - 1 ));
      val var_and_type =  ListPair.zip((map (Vr.string_of_name) 
                                      (Vr.NSet.list_of varset)),
                                       list_of_constr_types);
      fun convert_tuple_to_start (name,a_typ) = 
          (Free(name , Type (a_typ,[])));
     in 
      map convert_tuple_to_start  var_and_type  end;



(*to try use on
 my_convert_data_to_start  eg_type2;*)

fun my_convert_data_to_start varset data = map (my_convert_constr_to_start
                                           varset)
                                            (map snd data);



(* given the arity of the functions, the names of the extra terms and their tipes (as lists), returns a list of extra terms
TRY ON -> make_extra_terms 2 name_extra_terms  type_extra_terms;*)

exception type_extra_terms_too_little
exception name_extra_terms_too_little
fun  make_extra_terms2 1 _ _ = []
   | make_extra_terms2 _ [] _ = raise name_extra_terms_too_little
   | make_extra_terms2 _  _ [] = raise type_extra_terms_too_little
   | make_extra_terms2 arity (name::names) (typ::types) =
                                     (Free(name, typ)) :: 
                                     (make_extra_terms2 (arity -1) names types);

(* given the arity of the functions, the names of the extra terms and their tipes (as lists), returns a list of extra terms
TRY ON -> make_extra_terms 2 name_extra_terms  type_extra_terms;*)

fun make_extra_terms n terms_table = 
    make_extra_terms2 n (map Tr.dest (Tr.NTab.keys terms_table)) 
                         (Tr.NTab.values terms_table) ;


(* given a constructor as a list of terms, the arity of the function we want to construct, AN EXTRA_TERMS TABLE, and the returning type of the function we want to construct, it returns a list of term where the recursive function is applied on recursive terms, returning th e specified type
TRY ON -->  
           val start2 = 
                 initial_typ  "FUN" 2 extra_terms_table "TRYTRYTRY" eg_terms; *)


fun initial_typ _ _  _ _ [] = []
    | initial_typ  name_fun arity terms_table typ_name (var::constr)   =
         if && ((Term.type_of var) = (Type(name_data,[])))
              (not(head_name_of var = "null"))
            then   
                let 
                val function = 
                (Free ( name_fun,
                   ((List.take( (Tr.NTab.values terms_table),
                                (arity-1))) @ [Term.type_of var])
                         ---> (Type(typ_name,[]))));
                val extra_terms = make_extra_terms arity 
                                                 terms_table;

                val applied_function =  Term.betapplys (function,
                                                        (extra_terms @ [var]));

                in ( applied_function :: (initial_typ  name_fun arity 
                                                terms_table  typ_name constr))
                end
         else   var ::(initial_typ  name_fun arity terms_table typ_name constr );


(* TRY ON --> initial_data_typ "FUN" 2 a_data "TRYTRYTRY";*)
fun initial_data_typ name_fun arity terms_table data typ_name =
    map  (initial_typ name_fun arity terms_table typ_name) data;


(* this given a constructor as a list of term and the arity of the function we want to construct, it returns a list of lists of terms where the recursive function is applied on recursive terms, returning all teh possible types
TRY ON -->  all_initial_data   "FUN" 2 a_data;  *) 

fun all_initial_data  name_fun arity terms_table data = map 
                             (initial_data_typ name_fun arity terms_table data) 
                             (map Dn.dest (Dn.NSet.list_of data_names));


(* TRY ON-->split_term_on_function plus (List.nth(a_data,1));*)
fun split_term_on_function func terms = 
   let 
    val (type_arg_func,return_type_func) =(Term.strip_type( Term.type_of func));
    val num_argument_func = length type_arg_func;
    val taken_terms = List.take( terms, num_argument_func);
    val not_taken_terms =  List.drop( terms, num_argument_func);
   in (taken_terms,not_taken_terms) end;


(*given a function subtitutes the first n terms, where n is the arity of the function, with  the function applied to this terms.
NOTE: in the 0 or 1 case, it just subd=stitues the numbers with the term   
 NOTE: this does not look at the type according
 TRY ON --> sub_hd_with_function plus (List.nth(a_data,1)); *)

exception trying_to_substiture_other_type_with_integer
fun sub_hd_with_function  func terms = 
              if  ((head_of (hd terms)) = func) (*(hd terms) = func*)
                 then []
              else if && 
                     (&& (func = zero_fun)
                         ((Term.type_of (hd terms)) =  (Type("nat",[]))))
                              (Term.size_of_term (hd terms) = 1)
                 then 
                    zero_fun ::(tl terms)
              else if  &&
                       (&& (func = one_fun)
                           ((Term.type_of (hd terms)) =  (Type("nat",[]))))
                              (Term.size_of_term (hd terms) = 1)
                         then
                         one_fun ::(tl terms)
                         
              else 
                  let 
                     val (slip_terms as (taken_terms,not_taken_terms))=
                            split_term_on_function func terms;
                  in 
                   (Term.betapplys (func,taken_terms))
                   :: (not_taken_terms)
                   end;


(* states if a  function can be applied to a list of terms*)
fun can_be_applied  func term = 
   let 
     val (type_arg_func,return_type_func) = (Term.strip_type( Term.type_of func));
     fun type_of_list terms  = map (Term.type_of) terms;
   in 
     if (length type_arg_func) <= (length term)
        then (
             type_arg_func =  
             List.take(type_of_list term, (length (type_arg_func)))
             )
     else false end; 


(*simplyfies: multiplication by 0; multiplication by 1; addition by 0
*)

exception trying_to_simplify_func_failed
fun simplify func = 
       let 
         val (hd_fun, variables) =   Term.strip_comb func;
         fun not_unit_term unit = 
             if Bool.not((length variables) = 2) 
                then raise trying_to_simplify_func_failed
             else if (hd variables) = unit then List.nth(variables,1)
             else hd variables;
       in
             if hd_fun = times
                 then (
                     if(my_member zero_fun variables) 
                         then zero_fun
                     else if (my_member one_fun variables)
                         then not_unit_term one_fun
                     else func
                      )
             else if Term.head_of func = plus
                 then(
                      if(my_member zero_fun variables) 
                         then not_unit_term zero_fun
                      else func
                     )
             else func
        end;



(* substitue terms with a function just if it sounds.*)

fun sub_hd_if_valid func term = 
        if can_be_applied func term
        then 
            let 
              val subs = sub_hd_with_function func term;
            in map simplify subs
            end
        else [];

(*applies a function to the last "pos" terms of a list of terms*)
fun apply_at_position 0 func term = []
       | apply_at_position pos func term =
           let
              val used_terms = get_arity_elem_from_list pos term;
              val sub_used_terms = sub_hd_if_valid  func used_terms;
           in 
              if sub_used_terms = []
              then []
              else  (List.take (term, ((length term) - pos))) @
                    sub_used_terms
            end;

(*applies a function wherever is possible in a list of terms
try with -->  val try1 = sub_fun_to_terms times start4;
              val try2 = sub_fun_to_terms plus (hd try1);
*)
fun sub_fun_to_terms func term = 
  let 
    val interactions = length term;
    fun interate_apply_at_position 0 _ term = []
        | interate_apply_at_position pos func term = 
                           if apply_at_position pos func term = []
                           then interate_apply_at_position (pos-1) func term
                           else
                                [apply_at_position pos func term] @ 
                                interate_apply_at_position (pos-1) func term;
   in  interate_apply_at_position interactions func term
   end;
        

(* applies all the functions from a list to all the possible parts in  a list of terms*) 
(*****************fun substitute_list_to_terms [] term = [term]************)
fun substitute_list_to_terms [] term = []
   | substitute_list_to_terms  (func :: functions) term  = 
                        (sub_fun_to_terms  func term) @ 
                        (substitute_list_to_terms functions term);

(* applies all the functions from a list to all the possible parts in  a list of list of terms*) 
fun substitute_all_fun_all_terms  list_of_fun []  = []
   | substitute_all_fun_all_terms list_of_fun (term::terms)  = 
                               ((substitute_list_to_terms list_of_fun term) @
                               (substitute_all_fun_all_terms list_of_fun terms ));




(* constructs all the possible functions given a constructor and some initial functions*)

fun construct_all_functions list_of_fun terms 0 = []
   |construct_all_functions  list_of_fun terms n = 
      let 
        val step= substitute_all_fun_all_terms list_of_fun terms;
        fun length_is_one list = (length list) = 1;
        fun length_is_not_one list = Bool.not (length_is_one list);
        val compleated = filter length_is_one step;
        val not_compleated = filter length_is_not_one step;
      in 
       compleated @  (construct_all_functions list_of_fun  not_compleated (n-1))
      end;


(* eliminates all doubles from all the possible functions given a constructor and some initial functions. If the constuctor is a unit, it returns all the units of allthe types*)

fun all_functions_for_constructor funcs term = 
              if term = [] 
                 then [one_fun, zero_fun] @  units_list
              else 
                if my_member unit term
                     then [one_fun, zero_fun] @  units_list
              else
                let 
                  val all_funs = construct_all_functions  funcs 
                                                          [term] 
                                                          (length term); 
                in eliminate_double (merge_list_of_lists  all_funs )  end;
     


(*constuct all the possible functions given a constructor and some initial functions, and does a partition between the types that the functions rreturn *) 


fun populate_initilal_list [] initial_list = initial_list
          |  populate_initilal_list (f::funs) initial_list = 
              let
                val this_typ = Term.type_of  f;
                val list_of_typs =map TheoryEdit.make_term_type 
                                   (map Dn.dest (Dn.NSet.list_of data_names ));
                val right_pos =  element_at_position this_typ list_of_typs;
                val this_list_of_typ = List.nth(initial_list, right_pos);
                val next_list_of_typ= f :: this_list_of_typ;
                val next_initial_list = substitute_in_list_pos  
                                          right_pos next_list_of_typ initial_list;
              in populate_initilal_list funs next_initial_list
              end;
                 

fun partition_by_returning_type funcs terms = 
    let 
       val constr_funs = all_functions_for_constructor funcs terms;
       val initial_returning_lists =  make_list_of_empty_lists 
                                    (length  (Dn.NSet.list_of data_names ));
    in populate_initilal_list constr_funs initial_returning_lists end;


(* it organises the returning functions for each constructor into types *)

fun take_typ_consisten_funcs n [] = []
   | take_typ_consisten_funcs n (p::part) =  (list_of_list(List.nth(p,n))):: (take_typ_consisten_funcs n part);


(* creates a list giving all the possible functions generated froma data type returning ecah different type
TRY ON --> all_functions  a_data (initial_functions,(Type("MyMain.dataType_b",[])));*)



fun all_functions  data  (funcs,ret_typ)= 
   let 
      val  constr_funs = map (all_functions_for_constructor funcs) data;
      fun has_right_typ func =  Term.type_of  func =  ret_typ; 
      val just_right_typ_funs = map (filter has_right_typ)  constr_funs;
      val list_of_list_funs = map list_of_list just_right_typ_funs;
      val merge_fun =  cross_prod_list list_of_list_funs  ; 
    in merge_fun  end;


(*fun all_functions  data funcs= 
   let 
       val all_partitions = map (partition_by_returning_type funcs) data;  (*Term.term list LIST.list list*)
       fun list_of_fun_to_compose 0 = [take_typ_consisten_funcs 0 all_partitions]
          |  list_of_fun_to_compose n = (take_typ_consisten_funcs n all_partitions) :: (list_of_fun_to_compose (n-1));
       val  list_of_fun_to_compose = list_of_fun_to_compose ((length list_avaible_types)-1);
       val merge_fun =  map cross_prod_list  list_of_fun_to_compose ; 

    in merge_fun  end;
*)



(*Given a constructor and its name it constructs the constructor function to then add to teh list on initial functions *) 



fun make_costr_fun (cons_name,constr) = 
    let 
       val costr_name2 = name_data ^ "." ^ cons_name;
       val costr_type = (map Term.type_of constr) --->
                           (Type(name_data,[]));
    in Const(costr_name2,costr_type ) end;

(*create the recursive function declariation assuming it will return a object of the determined type
TRY ON -->  make_rec_fun_typ "FUNFUN"  2 (Type("nat",[]));
*) 

fun make_rec_fun_typ   name_fun arity typ = 
   let 
     val type_extra_terms = List.take((Tr.NTab.values extra_terms_table), arity  -1);
     val type_func_arguments = (Tr.NTab.values extra_terms_table) @ 
                               [Type (name_data ,[])]  ;
     val func_to_add = 
           Free(name_fun,type_func_arguments ---> typ)        
     in  func_to_add end;


(* Given a constructor and an arity construct a list of terms in the order they will be taken to built the definition of functions

TRY ON -->  update_constructor_wit_extra_terms (hd eg_data) 3;

fun update_constructor_with_extra_terms  arity const= 
    let
      val extra_terms =  make_extra_terms arity name_extra_terms type_extra_terms;
    in extra_terms @ const
    end; 
*)


(*check if a particular terms appears free in a function i.e. not witin a recursive call of the function
TRY ON -->

val aaa = create_rhs "FUN" initial_functions a_data 2;

 val bbb = List.nth(List.nth(snd aaa,2),1);
check_if_arity_term "FUN" (Free("T1", Type("nat",[]))) bbb;
check_if_arity_term "FUN" one_fun bbb;

val bbb = List.nth(List.nth(snd aaa,20),1);
check_if_arity_term "FUN" (Free("T1", Type("nat",[]))) bbb;
*)

fun check_if_arity_term  name_fun term  func = 
   if  (Term.size_of_term func) = 1
      then 
           term = func  
   else if  head_name_of func = name_fun 
       then false
   else
   let 
     val (hd_fun, args) = Term.strip_comb func;
     val one_of_this_arguments = my_member term args 
   in
     if ( one_of_this_arguments = true)
         then true
     else 
       check_if_arity_term_in_args  name_fun term args      
     end

and 

 check_if_arity_term_in_args  name_fun term [] = false
    | check_if_arity_term_in_args  name_fun term (h::t) = 
       if 
         check_if_arity_term name_fun term h
              then true
       else check_if_arity_term_in_args  name_fun term t;
            


(*checks if every terms in a list of terms appear in at least one functiom each a list of functio
TRY ON -->
val aaa = create_rhs "FUN1" initial_functions a_data 2;
 val bbb = List.nth(List.nth(snd aaa,20),1);
 val ccc = List.nth(List.nth(snd aaa,2),1);

check_all_terms_in_functions "FUN1" [(Free("T1",Type("nat",[]))), zer_fun] [bbb,ccc];
check_all_terms_in_functions "FUN1" [(Free("T1",Type("nat",[]))), one_fun] [bbb,ccc]; 

 *)

fun check_all_terms_in_functions  name_fun  [] _ = true
  | check_all_terms_in_functions  name_fun _  [] = false
  | check_all_terms_in_functions  name_fun  (t::term) (f::funs) = 
     if 
       check_if_arity_term name_fun t f
     then 
       check_all_terms_in_functions name_fun term (f::funs)
     else 
       check_all_terms_in_functions name_fun (t::term) funs;

        
(* thi generates fuctions just with the recursive definition*)        

(*fun create_rhs2 name_fun funcs data arity = 
    let 
      val consts_with_names =  make_tuples_costr_name (tl constructors_names) data;
      val costr_funs = map make_costr_fun consts_with_names;
      val funs_list = funcs @ costr_funs; 
      val initial_data_int  = map (initial_int name_fun  arity) data;
      val initial_data_dt = map (initial_dt name_fun arity) data;
      val extra_terms =  make_extra_terms arity name_extra_terms type_extra_terms;
      fun update_constructor_with_extra_terms  cons = extra_terms @ cons ;
      val updated_initial_data_int = map update_constructor_with_extra_terms initial_data_int; 
      val updated_initial_data_dt = map update_constructor_with_extra_terms initial_data_dt; 
      val rec_func_int = make_rec_fun_int name_fun  arity;
      val rec_func_dt = make_rec_fun_dt name_fun  arity;
      fun is_rec_fun x = || (x = rec_func_int) (x = rec_func_dt);
      fun has_one_rec_fun [] = false
         | has_one_rec_fun (h::t)= 
               if (Term.exists_subterm is_rec_fun h)  then true
                                     else has_one_rec_fun t;
      val (int_int,int_dt) = all_functions
fun make_con_type typ_name = [Typ(Type(typ_name,[]))]; 

fun make_term_type typ_name = (Type(typ_name,[]));  funs_list updated_initial_data_int;
      val (dt_int,dt_dt) =  all_functions funs_list updated_initial_data_dt;
      val recursive_int_int =  filter  has_one_rec_fun   int_int;
      val recursive_dt_dt =  filter  has_one_rec_fun    dt_dt;
      val arity_consistent_int_int = filter (check_all_terms_in_functions name_fun extra_terms) recursive_int_int;
      val arity_consistent_dt_dt = filter (check_all_terms_in_functions name_fun extra_terms) recursive_dt_dt;
    in
    (arity_consistent_int_int, arity_consistent_dt_dt)
    end;  
*)



(* checks if at least one of the rhs on a function contains one of the new created functions (recursive ones)
 Rey on -->  has_a_rec_fun   ( hd (snd aaa));*)
fun has_a_rec_fun rhs  = 
   let 
      fun list_all_frees [] = []
        | list_all_frees (r :: rhs) = Term.add_free_names r 
                                     (list_all_frees rhs);
      val all_frees =  (list_all_frees rhs);
      fun is_in_rec_list [] = false
        | is_in_rec_list (h::t)=
             if my_member h (map (Fn.dest) 
                                     (Fn.NSet.list_of functions_names)) 
              then true
             else is_in_rec_list t;
       in  is_in_rec_list all_frees  end;

  


fun create_rhs name_fun funcs  data arity = 
    let 
      val term_typ = map  TheoryEdit.make_term_type (map Dn.dest
                                         (Dn.NSet.list_of data_names));
      val consts_with_names =  make_tuples_costr_name (map Cn.dest
                                         (Cn.NSet.list_of con_names))
                                                      data;
      val costr_funs = map make_costr_fun consts_with_names;
      val rec_funs = map (make_rec_fun_typ name_fun  arity) term_typ;
      fun make_initial_funs this_rec_fun = funcs @ costr_funs  @ [this_rec_fun];
      val initial_funs  = map make_initial_funs rec_funs;
      val extra_terms =  make_extra_terms arity  extra_terms_table;
      fun update_constructor_with_extra_terms  cons = extra_terms @ cons ;
      val uptaded_data = map (update_constructor_with_extra_terms) data;
      val funs_with_type =  list_of_tuples initial_funs term_typ;
      val all_possible_funs = map (all_functions uptaded_data)  funs_with_type;  
      val recursive_fun = map (filter  has_a_rec_fun) all_possible_funs;
      val arity_consistent_funs = map (filter 
                                    (check_all_terms_in_functions name_fun extra_terms)) 
                                    recursive_fun;
    in
        arity_consistent_funs
    end;  









(*
 fun has free 
use Term.add_term_frees (bbb, []); to find if a function has at list one of the function "FUN1" "FUN2" etc.. (in name_funs).
If not throw it away! YESS!!!
*)

