(* this differs from the first version as it does not always applied a function recurrsevly on the rhs 
example if data T = c0(T,nat) || c1(nat, nat)
then a function does NOT have to be in the following format:
fun1(c0(T,nat))= fun1(T)....
and hence fun1 does NOT have to appear on the lhs at all
*)

val name_variables = ["a","b","c","d","e","f","g","e","f","g","h","i","l","m","n"];val constructors_names = ["null", "C0", "C1", "C2", "C3", "C4","C5", "C6", "C7","C8", "C9" ];
val name_funs = ["FUN1","FUN2", "FUN3", "FUN4"];

val availble_functions = [ Const("HOL.plus_class.plus", Type("fun", [Type("nat", []), Type("fun", [Type("nat", []), Type("nat", [])])])),Const("HOL.times_class.times", Type("fun", [Type("nat", []), Type("fun", [Type("nat", []), Type("nat", [])])]))];
val zer_fun =  (Const("HOL.zero_class.zero", Type("nat",[])));
val one_fun =  (Const("HOL.one_class.one", Type("nat",[]))) ;

val initial_functions = zer_fun :: one_fun :: availble_functions;


  
(*************************** examples*********************************************)
val plus = hd availble_functions;
val times = hd (tl availble_functions);
val recu = Free("RECFUN", Type("fun", [Type("MyMain.dataType_b", []), Type("nat", [])]));
val con_fun = Const("C0", Type("fun", [Type("MyMain.dataType_b", []),  Type("fun", [Type("nat", []), Type("fun", [Type("nat", []),Type("MyMain.dataType_b", [])])])]));
 val eg_type1 = Type("fun",[Type("nat", []), Type("MyMain.dataType_b", [])]);

 val eg_type2= Type("fun",[Type("MyMain.dataType_b", []), Type("fun",[Type("nat", []), Type("nat", [])])]);

 val eg_type3 = Type("fun",[Type("nat", []), Type("fun", [Type("nat", []), Type("fun", [Type("nat", []), Type("nat", [])])])]);


val initial_functions2 = zer_fun  :: availble_functions;
val initial_functions3 = zer_fun  :: (tl availble_functions);

(*************************** end examples**********  *****************************)

exception  list_of_type_on_unregular_type;
fun list_of_types  (Type (typ, []))= [typ]
   | list_of_types (Type (_, (h::t))) = (list_of_types h) @  (list_of_types (hd t))
   | list_of_types _ = raise list_of_type_on_unregular_type;


(*to try use on 
 my_convert_constr_to_start eg_type1; my_convert_constr_to_start eg_type2; *)

fun my_convert_constr_to_start typ = 
    let 
      val temp = list_of_types typ
      val list_of_constr_types= List.take(temp,((List.length temp) - 1 ));
      val var_and_type =  ListPair.zip(name_variables,list_of_constr_types);
      fun convert_tuple_to_start (name,a_typ) = 
          (Free(name , Type (a_typ,[])));
     in 
      map convert_tuple_to_start  var_and_type  end;

(*to try use on
 my_convert_data_to_start eg_data1;*)

fun my_convert_data_to_start data = map my_convert_constr_to_start 
                                    (map snd data);


(*********************************** TO AUTOMATE *******************************)
val name_data = "MyMain.dataType_b";
val type_extra_terms =  
    [Type("nat",[]), Type("nat",[]),Type("nat",[]), Type("nat",[]) ];
val name_extra_terms = ["T1","T2","T3","T4","T5","T6","T7"];
val unit =  (Const("null",Type(name_data,[])));
(******************************** END TO AUTOMATE *******************************)

(* given the arity of the functions, the names of the extra terms and their tipes (as lists), returns a list of extra terms
TRY ON -> make_extra_terms 2 name_extra_terms  type_extra_terms;*)

exception type_extra_terms_too_little
exception name_extra_terms_too_little
fun  make_extra_terms 1 _ _ = []
   | make_extra_terms _ [] _ = raise name_extra_terms_too_little
   | make_extra_terms _  _ [] = raise type_extra_terms_too_little
   | make_extra_terms arity (name::names) (typ::types) =
                                     (Free(name, typ)) :: 
                                     (make_extra_terms (arity -1) names types);

;

(*************************** examples*********************************************)
val start = my_convert_constr_to_start eg_type2;
val start3 = my_convert_constr_to_start eg_type1;
val start4 =  my_convert_constr_to_start eg_type3;

val data =  eg_type2;

(*************************** end examples*****************************************)

fun split_term_on_function func terms = 
    let 
      val (type_arg_func,return_type_func) =(Term.strip_type( Term.type_of func));
      val num_argument_func = length type_arg_func;
      val taken_terms = List.take( terms, num_argument_func);
      val not_taken_terms =  List.drop( terms, num_argument_func);
    in (taken_terms,not_taken_terms) end;


(*given a function subtitutes the first n terms, where n is the arity of the function, with  the function applied to this terms.
NOTE: in the 0 or 1 case, it just subd=stitues the numbers with the term*)          

(*
exception trying_to_substiture_other_type_with_integer
fun sub_hd_with_function  func terms = 
              if  (hd terms = func)
                 then []
              else if (func = zer_fun)
                 then (
                     if (Term.type_of (hd terms)) =  (Type("nat",[]))
                       then 
                       (Const("HOL.zero_class.zero", Type("nat",[]))) ::(tl terms)
                       else raise trying_to_substiture_other_type_with_integer
                    )
              else if   (func = one_fun) 
                 then (
                      if (Term.type_of (hd terms)) =  (Type("nat",[]))
                         then
                         (Const("HOL.one_class.one", Type("nat",[]))) ::(tl terms)
                         else raise trying_to_substiture_other_type_with_integer
                      )
              else 
                  let 
                     val (slip_terms as (taken_terms,not_taken_terms))=
                            split_term_on_function func terms;
                  in 
                   (Term.betapplys (func,taken_terms))
                   :: (not_taken_terms)
                   end;
*)

exception trying_to_substiture_other_type_with_integer
fun sub_hd_with_function  func terms = 
              if  (hd terms = func)
                 then []
              else if && 
                      (&& (func = zer_fun) 
                         ((Term.type_of (hd terms)) =  (Type("nat",[]))))
                              (Term.size_of_term (hd terms) = 1)
                 then 
                       (Const("HOL.zero_class.zero", Type("nat",[]))) ::(tl terms)
              else if  &&
                        (&& (func = one_fun) 
                           ((Term.type_of (hd terms)) =  (Type("nat",[]))))
                              (Term.size_of_term (hd terms) = 1)
                         then
                         (Const("HOL.one_class.one", Type("nat",[]))) ::(tl terms)
                         
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
                     if(my_member zer_fun variables) 
                         then zer_fun
                     else if (my_member one_fun variables)
                         then not_unit_term one_fun
                     else func
                      )
             else if Term.head_of func = plus
                 then(
                      if(my_member zer_fun variables) 
                         then not_unit_term zer_fun
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

fun all_functions_for_constructor funcs term= 
              if term = [] 
                 then [one_fun, zer_fun, unit]
              else 
                if my_member (Const("null",  Type(name_data,[]))) term
                  then [one_fun, zer_fun, unit]
              else
                let 
                  val all_funs = construct_all_functions  funcs 
                                                          [term] 
                                                          (length term); 
                in eliminate_double (merge_list_of_lists  all_funs )  end;
     

 
         

(*constuct all the possible functions given a constructor and some initial functions, and does a partition between the ones that return a natural and the ones that don't *) 

fun partition_by_returning_type funcs terms = 
    let 
       val constr_funs = all_functions_for_constructor funcs terms;
       fun returns_a_nat term = (Term.type_of  term) =  (Type("nat",[]))
    in  List.partition returns_a_nat constr_funs end;



(* creates a tuple giving all the possible functions generated froma data type returning a nat, and  all the possible functions generated froma data type returning a datatype 
TRY ON -->  val aaa = all_functions initial_functions2 [start2,start4, start2];*)

fun all_functions funcs data = 
   let 
       val all_partitions = map (partition_by_returning_type funcs) data;
       val  integer_fun =map list_of_list ( map fst all_partitions);
       val data_fun = map list_of_list (map snd all_partitions);
       val merge_integer_fun =  cross_prod_list integer_fun; 
       val merge_data_fun =  cross_prod_list data_fun; 
    in (merge_integer_fun, merge_data_fun  ) end;


(*Given a constructor and its name it constructs the constructor function to then add to teh list on initial functions *) 

fun make_costr_fun (cons_name,constr) = 
    let 
       val costr_name2 = name_data ^ "." ^ cons_name;
       val costr_type = (map Term.type_of constr) --->
                           (Type(name_data,[]));
    in Const(costr_name2,costr_type ) end;
 


(*create the recursive function declariation assuming it will return an integer
TRY ON -->  make_rec_fun_int "FUNFUN"  2;
*) 

fun make_rec_fun_int  name_fun  arity= 
   let 
     val type_extra_terms = List.take(type_extra_terms, arity  -1);
     val type_func_arguments = type_extra_terms @ [Type (name_data ,[])] ;
     val func_to_add = 
           Const(name_fun,type_func_arguments ---> (Type("nat",[])));
     in  func_to_add end;


(*create the recursive function declariation assuming it will return a object of type datatype
TRY ON -->  make_rec_fun_dt "FUNFUN"  2;
*) 

fun make_rec_fun_dt  name_fun arity= 
   let 
     val type_extra_terms = List.take(type_extra_terms, arity  -1);
     val type_func_arguments = type_extra_terms @ [Type (name_data ,[])]  ;
     val func_to_add = 
           Const(name_fun,type_func_arguments --->(Type(name_data,[])));
     in  func_to_add end;

(* Given a constructor and an arity construct a list of terms in the order they will be taken to built the definition of functions

TRY ON -->  update_constructor_wit_extra_terms (hd eg_data) 3;*)

fun update_constructor_with_extra_terms arity constr  = 
    let
      val extra_terms =  make_extra_terms arity name_extra_terms type_extra_terms;
    in extra_terms @ constr
    end;

(*Given a list of initial functions, a data type and an arity it creates all the functions as tuples. 
TRY ON -->  val aaa = create_rhs (hd name_funs) initial_functions2 [start,start4, start] 2; *)



fun create_rhs name_fun funcs data arity = 
    let 
      val consts_with_names =  make_tuples_costr_name (tl constructors_names) data
      val costr_funs = map make_costr_fun consts_with_names;
      val rec_func_int = make_rec_fun_int name_fun  arity;
      val rec_func_dt = make_rec_fun_dt name_fun  arity;
      val initial_fun_int = funcs @ costr_funs  @ [rec_func_int];
      val initial_fun_dt = funcs @ costr_funs  @ [rec_func_dt];
      val uptaded_data = map (update_constructor_with_extra_terms arity) data;
      val (int_int,int_dt) = all_functions initial_fun_int uptaded_data;
      val (dt_int,dt_dt) = all_functions initial_fun_dt  uptaded_data;
    in
       (int_int,dt_dt)
    end;
     
         
    
(********************* EXTRA FUN : to delete  **********************************)
fun my_member _ [] = false
   | my_member a (h::t) = if a = h then true else my_member a t;

fun eliminate_double [] = []
| eliminate_double (h::t) = if my_member h t then  eliminate_double t
else h :: (eliminate_double t);

fun return_double [] = []
| return_double (h::t) = if my_member h t then  h :: (return_double t)
else  (return_double t);

(********************* END  EXTRA FUN : to delete  ******************************)
