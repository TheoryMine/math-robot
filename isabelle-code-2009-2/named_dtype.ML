
(* *)
signature NAMED_DTYPE = 
sig 
  
  (* Fn.NTab is table from constructor name to the constructor arguments. *)
  datatype T = Ndtyp of (DataGen.elem_typ list) Fn.NTab.T;

  val dtyp_of : T -> DataGen.dtyp; 

  val pretty : T -> Pretty.T;
  val print : T -> unit;

end;

(* *)
structure NamedDType = 
struct
  (*  *)
  datatype T = Ndtyp of (DataGen.elem_typ list) Fn.NTab.T;

  fun pretty (Ndtyp ctab) = 
      Pretty.block 
        (Pretty.separate " | " 
          (map (fn (c,el) => Pretty.block 
                 [Fn.pretty_name c, DataGen.ml_pretty_elem_list el])
               (Fn.NTab.list_of ctab)));

  (* ML pretty for serialisation *)
  fun ml_pretty_named_dtyp_c (n,el : DataGen.elem_typ list) = 
      Pretty.block [Pretty.str "(Fn.mk ", 
        Pretty.quote (Fn.pretty_name n), Pretty.str ", ", DataGen.ml_pretty_elem_list el,
        Pretty.str ")"];

  fun ml_pretty (Ndtyp ctab) = 
      Pretty.chunks 
        [ Pretty.str "NamedDType.Ndtyp (Fn.NTab.of_list ",
          Pretty.list "[" "]" (map ml_pretty_named_dtyp_c (Fn.NTab.list_of ctab)),
          Pretty.str ")"
        ];

  fun dtyp_of (Ndtyp ctab) = DataGen.DType (map snd (Fn.NTab.list_of ctab));

  fun ord t1 t2 = DataGen.dtype_ord (dtyp_of t1) (dtyp_of t2);

end;
