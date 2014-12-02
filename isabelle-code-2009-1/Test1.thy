theory Test1
imports FunDefs
begin

text {* Base types are natual numbers and boolean, called "n" and "b" *}
ML {* 
val n_tn = MThy.Tn.mk "n";
val b_tn = MThy.Tn.mk "b";

val base_types = 
    MThy.Tn.NTab.of_list 
      [(n_tn, @{typ "nat"}), 
       (b_tn, @{typ "bool"})];
*}

setup {* MThyData.map (update_typs (MThy.Tn.NTab.merge_disjoint base_types)) *}


text {* Create a datatype: 
datatype T0 = C0 bool bool 
            | C1 T0
*}

ML {* 
val datatype_name = "T0";
val dtyp = MThy.DType [([MThy.Typ b_tn, MThy.Typ b_tn]), ([MThy.Rec])];
*}

setup "mk_simple_datatype datatype_name dtyp"

print_theorems

text {* Create a function definition: 
fun f0 (C0 x y) z = z 
  | f0 (C1 x) z = C1 (f0 x z)
*}

ML {*
val funtion_name = "f0";
val t1 = @{term "Trueprop (f0 (Ca b1 b2) (y :: T0) = y)"};
val t2 = @{term "Trueprop (f0 (Cb x) (y :: T0) = Cb (f0 x y))"};
*}

setup "mk_simple_function funtion_name [t1,t2]";

print_theorems



text {* prove a simple theorem about the function *}

theorem "f0 (f0 x y) z = f0 x (f0 y z)"
by (induct x, simp_all) 




end;