use "dev/vanity_theorem_proving/TEMP_list_of_var";

PolyML.use "/home/s0566840/project-code/IsaP-trunk/IsaPlanner/src/dev/vanity_theorem_proving/TEMP_ROOT.ML";

val a_data =   new_data 3 2 0;

val fisrt_theory = create_theory_2 a_data (1,2,1);

val ( unit, name_data,name_funs, all_name_funs, initial_functions,  list_avaible_types,non_rec_typ, choosen_funcs) =
update_variables_with_new_theory ([0,1,2,3],[0,1,2,3],[0,1,2,3]) "MyMain.SECOND_DATA" ["NEWFUN1","NEWFUN2","NEWFUN3","NEWFUN4"] fisrt_theory;


PolyML.use "/home/s0566840/project-code/IsaP-trunk/IsaPlanner/src/dev/vanity_theorem_proving/TEMP_ROOT.ML";

val a_data2 =  new_data 2 2 0;
val second_theory = create_theory_2 a_data2 (0,2,1);
