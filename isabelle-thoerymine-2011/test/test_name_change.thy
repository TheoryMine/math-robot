theory test_name_change 
imports "../rename"
begin

ML {*
GreekNChange.chrlist_of_int 4;


val a_thm = "f_13(f_2(x_213,(C_1(x_2,x_3,xaxf))),x_1)=x_1"
val char_list = explode a_thm;

val mw = "datatype MW = C_1 bool bool  | C_2 MW";
val f11= "f_1 (C_1 x_1 x_2) x_3 = x_3";
val f12 = "f_1 (C_2 x_1) x_2 = C_2 (f_1 x_1 x_2)";
val f21= "f_2 (C_1 x_1 x_2) x_3 = C_1 x_1 x_2";
val f22 = "f_2 (C_2 x_1) x_2 = f_1 x_2 (f_2 x_1 x_2)";
val thm2 = "f_2 x_1 (C_2 (C_1 x_2 x_3)) = x_1";
val thm3 = "f_1 (f_2 x_1 (C_1 x_2 x_3)) x_1 = x_1";
val q_thm= "f_1 (f_1 x_1 x_2) x_3 = f_1 x_1 (f_1 x_2 x_3)";
val r_thm = "f_1 x_1 (C_2 x_2) = C_2 (f_1 x_1 x_2)";
val proof= "by induction on x_1"
val try = "C_55";

term_to_html 0 r_thm ;

*}
