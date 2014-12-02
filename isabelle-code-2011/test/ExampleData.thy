theory ExampleData
imports TM_Data
begin

ML {* TM_Data.DType.Ctxt.print @{context}; *}

-- "Example usage: the 4 flavours of nat, used in the material world theory"
setup {* TM_Data.add_base_type (Tn.mk "B", @{typ "bool"}); *}
-- "Add the natural numbers as a base type"
setup {* TM_Data.add_base_type (Tn.mk "N", @{typ "nat"}); *}
ML {* TM_Data.DType.Ctxt.print @{context}; *}


text {* The Material World datatype... 
\begin{verb}
datatype MW = C_a bool bool 
            | C_b MW
\end{verb}
*}
setup {* TM_Data.add_new_datatype "MW" 
  (DataGen.DType [[ DataGen.Typ (Tn.mk "B"), 
                 DataGen.Typ (Tn.mk "B")],
               [ DataGen.Rec]]); *}
ML {* TM_Data.DType.Ctxt.print @{context}; *}

-- "testing code for data generation"
ML {* 
local open DataGen in 
  val nset = Tn.NSet.of_list [Tn.mk "N", Tn.mk "B"];
  val el0 = mk_bot_elem_list nset 2;

  val _ = print_all print_elem_list (elem_list_suc' nset) el0; 

  val dt0 = mk_bot_dtyp nset [1,2,3];
  val _ = print_all print_dtyp_code (dtyp_suc' nset) dt0; 

  val dt0 = mk_bot_dtyp nset [2,2];
  val _ = print_all print_dtyp_code (dtyp_suc' nset) dt0; 

  val _ = print_all print_dtyp_param 
          (suc_dtyp_param' {maxelems=3,maxconstrs=3}) [0]; 

  val sq1 = all_dtyps_upto nset {maxelems=2,maxconstrs=2};
  val _ = PolyML.print (length (Seq.list_of sq1));

  val sq2 = all_well_founded_rec_dtyps_upto nset {maxelems=3,maxconstrs=3};
  val sq2 = all_well_founded_rec_dtyps_upto nset {maxelems=2,maxconstrs=2};
  val sq2l = Seq.list_of sq2; (* all datatypes *)

  val _ = PolyML.print (length (map print_dtyp_code sq2l));
end;
*}
 
setup {* 
  fold 
    (fn x => (TM_Data.add_new_datatype Tn.default_name x))
    (sq2l)
*}
ML {* TM_Data.DType.Ctxt.print @{context}; *}

(* 

datatypes upto size (2,2): 55
well-founded rec datatypes upto size (2,2): 22

datatypes upto size (3,3): 1561
well-founded rec datatypes upto size (3,3): 1090

datatypes upto size (4,4): 61694
well-founded rec datatypes upto size (4,4): 52634

? how many of these are just instances of known polymorphic types, e.g. 
trees (upto size 3) and lists?

*)



end;
