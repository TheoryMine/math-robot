header{* Isabelle code to make simple definitions in ML *}
theory MFunDef
imports MDataDef
begin

ML {*
print_depth 100;
*}

ML {*
val all_consts = 
    (map Term.dest_Const [@{term "Suc"}, @{term "0 ::nat"}, @{term "op ="}]);

val init_ctab = ConstInfo.ConstInfoTab.empty 
  |> ConstInfo.add_const_to_cinfo @{theory} all_consts false ("op =", Sign.the_const_type @{theory} "op =")
  |> fold ConstInfo.update_constraints [@{thm IsaP_reflexive},  @{thm IsaP_eq_commute}]
  |> ConstInfo.add_datatype_to_cinfo @{theory} all_consts "nat";

val max_term_size = 11;
val max_vars = 3;
val init_sterm = Synthesis.init_any_sterm @{theory} init_ctab 14 3;
*}

setup {* Sign.add_consts_i [(@{binding "f0"}, @{typ "nat => nat => nat"}, NoSyn)] *}

ML {*
val ctxt = ProofContext.set_mode (ProofContext.mode_schematic) @{context};
fun read_term s = Syntax.read_term ctxt s;

Synthesis.synthesise_upto_given_term' Synthesis.is_hole_in_lhs init_ctab (read_term "f0 (Suc x) y = ?w") init_sterm;

*}


ML {*
ConstInfo.ConstInfo ConstInfo.ConstInfoTab.T

ConstInfo.mk_const_infos_ac;
Synthesis.restr_synthesis;
*}


ML {* 
(* 
structure MFun = struct local open MThy in

  datatype T = MFun of  
  {
    (* function to term table maps internal function names to 
       list of Isabelle terms that the functions defining equations  *)
    fttab : term list Fn.NTab.T,
    (* mapping from Isabelle full function symbol name to internal name (Fn.name) *)
    typtntab : Fn.name Symtab.table,
    (* the type in which a constructor occurs; 
       note: cod_nset = set of all used constructors *)
    cfmap : CnFnMap.T 
  }

  val empty = MData {typs = Tn.NTab.empty, typtntab = Symtab.empty, 
                    ctmap = CnTnMap.empty };


end; end; (* local; struct *)
*)
*}


ML {*
  val run_single_threaded = true;
  fun mk_simple_function name eqs thy =
      Theory_Target.init NONE thy
      |> Function_Fun.add_fun
           (* function package config *)
           Function_Common.default_config
           (* names for multually defined functions *)
           [(Binding.qualified_name name, NONE, NoSyn)] 
           (* names/attributes for defining theorems *)
           (map (fn t => ((Binding.qualified_name "", []), t)) eqs)
           run_single_threaded
      |> ProofContext.theory_of;
*}

ML {*
  

*}

end;