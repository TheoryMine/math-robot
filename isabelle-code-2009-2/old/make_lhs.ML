

(* This converts the function into a term, given the arity and the name of the function and the function returning type
TRY ON-->> crete_fun_declaration 2 "FUUN1" "nat";*)

fun crete_fun_declaration arity func_name typ = 
     let
        val extra_term_types = List.take( (Tr.NTab.values extra_terms_table),
                                          (arity-1));
        val fun_type = (extra_term_types @ [Type(name_data ,[])]) 
                           ---> (Type(typ,[]));
        val fun_dec = Free(func_name, fun_type);
      in 
      fun_dec  end;



(*this converts the function into a list of terms, each returning one of teh possible types
TRY ON--> all_fun_declaration 2 "FUN";
 *)
fun all_fun_declaration arity func_name = map 
                                   (crete_fun_declaration arity func_name)  
                                   (map Dn.dest (Dn.NSet.list_of data_names))  ;


(* declares the costructor as a term
try on --> create_constr start "C1"; *)

fun create_constr constr cons_name = 
    let 
       val costr_name2 = name_data ^ "." ^ cons_name;
       val costr_type = (map Term.type_of constr) --->
                           (Type(name_data,[]));
       val constr_declaration = Const
                                  (costr_name2,costr_type);

    in 
      Term.betapplys (constr_declaration, constr) end;


(* creates the lhs of a constructor given the arity teh function name, the costr name and the costructor(as a list). it returns a tuple, the first giving a function of returning type int, the second of returning type dayatype
try --> cons_lhs 2 "FUN" "CON" start*) 

fun cons_lhs  arity func_name cons_name constr= 
    let 
      val func_declaration =  all_fun_declaration  arity func_name;
      val extra_terms=  make_extra_terms arity extra_terms_table;
      val whole_costr= create_constr constr cons_name;      
      fun make_lhs_list [] = []
         | make_lhs_list (h::t) = Term.betapplys (h,(extra_terms @ [whole_costr])) ::
                                  (make_lhs_list t);
    in  make_lhs_list func_declaration  end;


(* same as cons_lh above but for unit constructor
try --> null_lhs 2 "FUN" (hd a_data);*)
fun null_lhs  arity func_name constr= 
    let 
      val func_declaration = all_fun_declaration  arity func_name;
      val extra_terms=  make_extra_terms arity extra_terms_table; 
      fun make_lhs_list [] = []
         | make_lhs_list (h::t) = Term.betapplys (h,(extra_terms @ constr)) ::
                                  (make_lhs_list t);
        in  make_lhs_list func_declaration end;


fun try  arity func_name (cons_name,constr) = 
     cons_lhs  arity func_name cons_name constr;


(*makes the lhs for a datatype, returning a list of tuples
try -->  make_lhs [start,start4,start] 2 "FUN" constructors_names; *)

(*exception costr_names_too_little 
fun make_lhs data arity func_name cons_names = 
           let 
              fun cons_lhs_2 (cons_name,constr) = 
                  cons_lhs  arity func_name cons_name constr;
               val names_and_constr =  make_tuples_costr_name cons_names data;
             in 
                  map cons_lhs_2 names_and_constr end;
*)

(*makes the lhs for a datatype, returning a tuple with two lists : fisrt with lhs returning int, second with lhs rerurning dt
try -->  make_lhs_a eg_data 2 "FUN" ( tl constructors_names); *)

exception costr_names_too_little 
fun make_lhs_a [] arity func_name _ = make_list_of_empty_lists (length  
                                                 (Dn.NSet.list_of data_names))
  | make_lhs_a _ _ _ [] = raise costr_names_too_little
  |  make_lhs_a (constr:: costr_list) arity func_name (name::cons_names)= 
       if constr = [Free("null", Type(name_data,[]))]
          then 
              let 
                val lhs_costr = 
                    null_lhs arity func_name  constr;
              in  distribute_elements_in_lists  lhs_costr 
                               (make_lhs_a costr_list arity func_name (name::cons_names)) end
       else
        let 
            val lhs_costr  = 
                 cons_lhs  arity func_name name constr;
        in distribute_elements_in_lists lhs_costr
                               (make_lhs_a costr_list arity func_name cons_names)
           end;





