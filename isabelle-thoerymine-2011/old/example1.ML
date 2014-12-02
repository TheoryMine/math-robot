(*************************************************************************************examples ******************************************************************************)
val plus = hd availble_functions;
val times = hd (tl availble_functions);
val recu = Free("RECFUN", Type("fun", [Type("MyMain.dataType_b", []), Type("nat", [])]));
val con_fun = Const("C0", Type("fun", [Type("MyMain.dataType_b", []),  Type("fun", [Type("nat", []), Type("fun", [Type("nat", []),Type("MyMain.dataType_b", [])])])]));
val eg_type1 = Type("fun",[Type("nat", []), Type("MyMain.dataType_b", [])]);
val eg_type2= Type("fun",[Type("MyMain.dataType_b", []), Type("fun",[Type("nat", []), Type("nat", [])])]);
val eg_type3 = Type("fun",[Type("nat", []), Type("fun", [Type("nat", []), Type("fun", [Type("nat", []), Type("nat", [])])])]);


val initial_functions2 = zer_fun  :: availble_functions;
val initial_functions3 = zer_fun  :: (tl availble_functions);

val start = my_convert_constr_to_start eg_type2;
(*val start2 = initial_typ (hd name_funs) 2 start "nat";*)
val start3 = my_convert_constr_to_start eg_type1;
val start4 =  my_convert_constr_to_start eg_type3;

val data =  eg_type2;

val a_data = convert_data_to_start (hd (data_type 3 2));
val a_data2 = convert_data_to_start (hd (data_type 2 2));

val artity_1_theories = [(1,0,0), (0,1,0), (0,0,1)];
val artity_2_theories = [(0,0,2), (0,1,1), (0,2,0), (1,0,1), (1,1,0), (2,0,0)];
val artity_3_theories = [(0,0,3), (0,1,2), (0,2,1),(0,3,0), (1,0,2), (1,1,1), (1,2,0),(2,0,1),(2,1,0),(3,0,0)];
val artity_4_theories = [(0,0,4), (0,1,3), (0,2,2),(0,3,1), (0,4,0), (1,0,3), (1,1,2), (1,2,1),(1,3,0),(2,0,2),(2,1,1),(2,2,0), (3,0,1), (3,1,0), (4,0,0)];


(******************************AN EXAMPLE ***************************************)

val eg_data =  [start,start4];
val eg_rhs_list= create_rhs (hd name_funs) initial_functions2 eg_data 1;
val eg_rhs = hd ( hd eg_rhs_list);
val eg_type_rhs = Term.type_of (hd eg_rhs);
val eg_lhs_tuple = make_lhs_a eg_data 1 (hd name_funs) constructors_names;
val eg_lhs = hd eg_lhs_tuple;
val eg_function = make_a_data_equation eg_rhs eg_lhs;


(*val a_theory =  create_theory_2 a_data (1,2,1);*)
(*****************************END:AN EXAMPLE ***********************************
************************************************************END examples ******************************************************************************)

