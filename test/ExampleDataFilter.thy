theory ExampleDataFilter 
imports ACFilterDtyp
begin

-- "Test code"

-- "Add the natural numbers as a base type; and also booleans."
setup {* TM_Data.add_base_type (Tn.mk "B", @{typ "bool"}); *}
setup {* TM_Data.add_base_type (Tn.mk "N", @{typ "nat"}); *}
ML {* TM_Data.DType.Ctxt.print @{context}; *}

-- "Create basic datatypes, max 2 elements and max 2 constructors, filtering lists and nats"
ML {* 
val nset = Tn.NSet.of_list [Tn.mk "N", Tn.mk "B"];
val (good_ds,bad_ds) = 
  fold 
    (fn d => fn (good_ds,bad_ds) => 
      if ACFilterDtyp.dtyp_is_ac_subsumed d then (good_ds,d::bad_ds)
      else (d::good_ds, bad_ds)
    )
    (Seq.list_of (DataGen.all_well_founded_rec_dtyps_upto nset {maxelems=2,maxconstrs=2}))
    ([],[]);
*}


setup {* TM_Data.add_new_datatype "L" 
  (DataGen.DType [[ DataGen.Typ (Tn.mk "B"), 
                 DataGen.Rec],
               []]); *}
ML {* TM_Data.DType.Ctxt.print @{context}; *}

setup {* TM_Data.add_new_datatype "L2" 
  (DataGen.DType [[],[DataGen.Rec, DataGen.Typ (Tn.mk "N")]]); 
*}

setup {* TM_Data.add_new_datatype "D" 
  (DataGen.DType [[DataGen.Typ (Tn.mk "B")],[DataGen.Rec, DataGen.Typ (Tn.mk "N"), DataGen.Typ (Tn.mk "B")]]); 
*}
ML {* TM_Data.DType.Ctxt.print @{context}; *}

ML{*
val dtyps  = Tn.NTab.list_of(TM_Data.DType.Thy.get_dtyps @{theory});
val [(_,d1),(_,d2),(_,d3)] = dtyps
val [t1,t2,t3] = map (fn (_, dt) => ACFilterDtyp.thmine_dtyp_to_term dt) dtyps;
*}


ML{*

val dtyp = "List.list";
val list_info = ThyConstraintParams.get_dinfo_in_thy @{theory} dtyp;
val list_t = ACFilterDtyp.isa_dtyp_to_term list_info;
Trm.print @{context} t1;
Trm.print @{context} t2;
Trm.print @{context} t3;
Trm.print @{context} list_t;

*}

ML{*
val subsumes1 = ACFilterDtyp.is_ac_subsumed d1;
val subsumes2 = ACFilterDtyp.is_ac_subsumed d2;
val subsumes3 = ACFilterDtyp.is_ac_subsumed d3;

*}

end;
