header{* Isabelle code to make simple definitions in ML *}
theory MDataDef
imports Main IsaP 
uses "metatheory.ML"
begin

ML {*
structure MData = 
struct local open MThy in

  datatype T = MData of  
  {
    (* type_tab : typ Tn.NTab.T maps Tn.name to Isabelle types *)
    typs : typ Tn.NTab.T,
    (* mapping from Isabelle full type name to internal type name (tn.name) *)
    typtntab : Tn.name Symtab.table,
    (* the type in which a constructor occurs; 
       note: cod_nset = set of all used constructors *)
    ctmap : CnTnMap.T 
  }

  val empty = MData {typs = Tn.NTab.empty, typtntab = Symtab.empty, 
                    ctmap = CnTnMap.empty };

  fun merge (MData rep, MData rep2) = 
    MData { (* takes second if there is an overlap *)
      typs = Tn.NTab.merge_joint (K true) (#typs rep) (#typs rep2),
      typtntab = Symtab.merge (K true) (#typtntab rep, #typtntab rep2),
      ctmap = CnTnMap.union_merge (#ctmap rep) (#ctmap rep)
    };

  fun get_typs (MData rep) = #typs rep;
  fun get_ctmap (MData rep) = #ctmap rep;
  fun get_typtntab (MData rep) = #typtntab rep;

  fun get_constrs mthy = CnTnMap.get_domset (get_ctmap mthy);

  fun update_typs f (MData rep) = 
    MData { typs = f (#typs rep), typtntab = #typtntab rep, ctmap = #ctmap rep };
  fun update_typtntab f (MData rep) = 
    MData { typs = #typs rep, typtntab = f(#typtntab rep), ctmap = #ctmap rep };
  fun update_ctmap f (MData rep) = 
    MData { typs = #typs rep, typtntab = #typtntab rep, ctmap = f(#ctmap rep) };

  val set_typs = update_typs o K;
  val set_typtntab = update_typtntab o K;
  val set_ctmap = update_ctmap o K;

  (* data stored in the Isabelle theory *)
  structure ThyData = Theory_Data
  (
    type T = T
    val empty = empty
    val extend = I
    fun merge (t1, t2) = merge (t1, t2)
  )


(* Creating a simple datatype

   name : string name of new datatype (will be changed to avoid clashes)
   MThy.dtyp : datatype representation to be created for the given name
   thy : theory being edited. 
*)
fun mk_simple_datatype name (DType ll) thy =
  let
    val data = ThyData.get thy;
    val full_name = Sign.full_name thy (Binding.qualified_name name);
    val rec_type = Type (full_name, []);
    val (tn, typs) = Tn.NTab.add (Tn.mk name, rec_type) (get_typs data);
    fun type_of Rec = rec_type
      | type_of (Typ n) = Tn.NTab.get typs n;
    val (cll, ctmap) = fold
          (fn l => fn (cll,ctmap) => 
             let val cn = Cn.NSet.new (CnTnMap.get_domset ctmap) Cn.default_name
             in ((cn,l)::cll, CnTnMap.add_to_dom cn tn ctmap) end)
          ll
          ([],get_ctmap data);
    val (thms, thy') = 
      Datatype.add_datatype 
        Datatype.default_config
        [name] 
        [([], Binding.qualified_name name, 
                NoSyn, 
                map (fn (c,Ts) => (Binding.qualified_name (Cn.string_of_name c), 
                                   map type_of Ts, NoSyn)) 
                    cll
          )] 
        thy;
  in thy' |> ThyData.map (set_ctmap ctmap
              o set_typs typs 
              o update_typtntab (Symtab.update (full_name, tn))
             )
  end;

end; (* local open MThy *)
end; (* struct *)
*}



end;