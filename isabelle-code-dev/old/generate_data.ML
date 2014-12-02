
(*This neds to be used just if you don't want to use unites (i.e. null constructor) in this case, substitue "base_cost" to "base_cost_2" in function "create_data_type" *)

(*fun create_base_constructor 1 = [[(Typ(Type("nat",[])))]]
   | create_base_constructor n = (((Typ(Type("nat",[]))) :: 
                                   (List.hd(create_base_constructor (n-1)))))::  (create_base_constructor (n-1));

*)
(*create_rec_length_constructors and create_rec_constructors are to create recursive costructors of length max n *) 

(*
val list_avaible_types = [name_data,"nat", "TRYTRY"];
val non_rec_typ = tl  list_avaible_types;
*)



(*fun data_type m n = 
    let 
       val args = create_data_type m n;
     in 
      fold (fn x => StrName.NTab.doadd (StrName.default_name, x)) args 
           StrName.NTab.empty

     end;
*)


(*converst a constuctor on initial format to make rhs *)
exception con_type_not_valid_in_convert_to_term_type
fun convert_con_to_term_type ("null", []) = [Free("null", Type(name_data,[]))]
   |  convert_con_to_term_type (_,[]) = []
   |  convert_con_to_term_type(_,con_typ) = 
     let
       fun  convert_con_to_term_typ2 Rec = Type(name_data, [])
           | convert_con_to_term_typ2 (Typ(Type(name_typ,[]))) = Type(name_typ,[])
           | convert_con_to_term_typ2 _ = raise con_type_not_valid_in_convert_to_term_type;
       val list_term_typ = map convert_con_to_term_typ2 con_typ
       val var_and_type =  ListPair.zip(name_variables,list_term_typ);
      fun convert_tuple_to_start (name,a_typ) = 
          (Free(name , a_typ));
     in map convert_tuple_to_start var_and_type end;
       
(*converst a  data on initial format to make rhs
TRY ON -->  val a_data = convert_data_to_start (hd (data_type 3 2)); *)      
fun convert_data_to_start data = map  convert_con_to_term_type data;

exception picked_data_to_big
fun new_data and_choice or_choice which_data = 
   let
     val isa_data_list = mk_isa_data_type and_choice or_choice;
     val is_length_not_ok = which_data >= (length isa_data_list);
     fun is_ok is_not_ok = if is_not_ok then raise picked_data_to_big else true;
     val is_ok = is_ok is_length_not_ok;
    in 
     convert_data_to_start(List.nth(isa_data_list,which_data)) end;
