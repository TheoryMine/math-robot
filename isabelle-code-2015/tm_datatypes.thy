theory tm_datatypes
imports "ACFilterDtyp"
begin

-- "Add the natural numbers as a base type; and also booleans."
setup {* TM_Data.add_base_type (Tn.mk "B", @{typ "bool"}); *}
setup {* TM_Data.add_base_type (Tn.mk "N", @{typ "nat"}); *}
ML {* TM_Data.DType.Ctxt.print @{context}; *}

-- "Create basic datatypes, max 2 elements and max 2 constructors, filtering lists and nats"
ML {* 
val nset = Tn.NSet.of_list [Tn.mk "N", Tn.mk "B"];
val all_possible_dtypes = 
  Seq.list_of (DataGen.all_well_founded_rec_dtyps_upto nset {maxelems=2,maxconstrs=2});
val (good_ds,bad_ds) = 
  fold
    (fn d => fn (good_ds,bad_ds) => 
      if ACFilterDtyp.dtyp_is_ac_subsumed d then (good_ds,d::bad_ds)
      else (d::good_ds, bad_ds)
    )
    all_possible_dtypes
    ([],[]);
writeln ("All possible Dtypes: " ^ (Int.toString (length all_possible_dtypes)));
writeln ("Number of good datatypes: " ^ (Int.toString (length good_ds)));
writeln ("Number of bad (subsumed by Isabelle) datatypes: " ^ (Int.toString (length bad_ds)));
*}

-- "add datatypes to theory"
setup {*
  fold 
    (fn x => (TM_Data.add_new_datatype Tn.default_name x))
    good_ds
*}
ML {* TM_Data.DType.Ctxt.print @{context}; *}

-- "Material world datatype is T_11: {[*Rec*], [B, B]} "
ML {* TM_Data.DType.Ctxt.print_dtyp @{context} (Tn.mk "T_11"); *}

-- "New scientist datatype is T_14: {[*Rec*], [N]} "
ML {* TM_Data.DType.Ctxt.print_dtyp @{context} (Tn.mk "T_14"); *}

-- "Theory for Advisory Panel stuff T_1 : {[*Rec*, N], [N, N]} "
ML {* TM_Data.DType.Ctxt.print_dtyp @{context} (Tn.mk "T_1"); *}

end