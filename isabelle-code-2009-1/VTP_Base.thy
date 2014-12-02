header{* TheoryMine/VTP Base Theory *}
theory VTP_Base
imports Main IsaP SimpleDefs
begin

text {* Base types are natual numbers and boolean, called "n" and "b" *}
ML {* 
val base_types = 
    MThy.Tn.NTab.of_list 
      [(MThy.Tn.mk "n", @{typ "nat"}), 
       (MThy.Tn.mk "b", @{typ "bool"})];
*}

ML {*
local open MThy in 
  val nset = Tn.NTab.get_nameset base_types;

  val (dtyp_tab, num_of_dtyps) = 
      fold 
        (fn (d,n) => (Tn.NTab.doadd (Tn.default_name, d), n + 1))
        (Seq.list_of (all_well_founded_rec_dtyps_upto nset {maxelems=3,maxconstrs=3}))
      (Tn.NTab.empty, 0);

  val sq2 = all_well_founded_rec_dtyps_upto nset {maxelems=3,maxconstrs=3};
  
  val _ = PolyML.print (length (Seq.list_of (Seq.map print_dtyp_code sq2)));
  val _ = PolyML.print (length (Seq.list_of sq1));

end;
*}

end;