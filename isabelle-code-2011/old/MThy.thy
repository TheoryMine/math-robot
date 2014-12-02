header{* Isabelle code to synthesise function definitions in ML *}
theory TheoryMineBasics 
imports Main IsaP
uses ("datagen.ML")
begin

-- "Name structures"
ML{*
(* TheoryMine Types: the data structures/types used in TheoryMine and the
   mechanisms to create new datatype *)
signature TM_TYPES =
sig
  (* function names (constructors and functions) *)
  structure Fn : SSTR_NAMES
  (* type names: elements/arguments in a constructor *)
  structure Tn : SSTR_NAMES 
  (* names for variables *)
  structure Vr : SSTR_NAMES
  (* Constant to Type-name map (for dependencies) *)
  structure FnTnMap : NAME_MAP 
    sharing FnTnMap.Sharing.Dom = Fn.Sharing
    sharing FnTnMap.Sharing.Cod = Tn.Sharing
  (* Type it is function's that are defined recursively on them *)
  structure TnFnMap : NAME_MAP
    sharing TnFnMap.Sharing.Dom = Tn.Sharing
    sharing TnFnMap.Sharing.Cod = Fn.Sharing
  (* Functions to Fcuntions they are used in map *)
  structure FnMap : NAME_MAP
    sharing FnMap.Sharing.Dom = Fn.Sharing
    sharing FnMap.Sharing.Cod = Fn.Sharing
end;

functor TM_Types(N : SSTR_NAMES) : TM_TYPES = 
struct
  structure NMap = NameMapFun(structure Dom = N and Cod = N);
  (* constructor names *)
  structure Fn : SSTR_NAMES = 
    struct open N; val default_name = N.mk "Fa"; end;
  (* type names: elements/arguments in a constructor *)
  structure Tn : SSTR_NAMES = 
    struct open N; val default_name = N.mk "Ta"; end;
  (* names for variables *)
  structure Vr : SSTR_NAMES = 
    struct open N; val default_name = N.mk "x_a"; end;
  structure FnTnMap = NMap;
  structure TnFnMap = NMap;
  structure FnMap = NMap;
end;

*}

text {* Construct the basic types *}
ML {*  
local structure TM_Types = TM_Types(SStrName); in open TM_Types end;
*}

text {* Data generation code *}
use "datagen.ML";

-- "testing code for data generation"
ML {*
local open DataGen in 
  val nset = Tn.NSet.of_list [Tn.mk "n", Tn.mk "b"];
  val el0 = mk_bot_elem_list nset 2;

  val _ = print_all print_elem_list (elem_list_suc' nset) el0; 

  val dt0 = mk_bot_dtyp nset [1,2,3];
  val _ = print_all print_dtyp_code (dtyp_suc' nset) dt0; 

  val dt0 = mk_bot_dtyp nset [2,2];
  val _ = print_all print_dtyp_code (dtyp_suc' nset) dt0; 

  val _ = print_all print_dtyp_param 
          (suc_dtyp_param' {maxelems=3,maxconstrs=3}) [0]; 

  val sq1 = all_dtyps_upto nset {maxelems=3,maxconstrs=3};
  val sq2 = all_well_founded_rec_dtyps_upto nset {maxelems=3,maxconstrs=3};
  
  val _ = PolyML.print (length (Seq.list_of (Seq.map print_dtyp_code sq2)));
  val _ = PolyML.print (length (Seq.list_of sq1));
end;
*}

(* 

datatypes upto size (3,3): 1561
well-founded rec datatypes upto size (3,3): 1090

datatypes upto size (4,4): 61694
well-founded rec datatypes upto size (4,4): 52634

? how many of these are just instances of known polymorphic types, e.g. 
trees (upto size 3) and lists?

*)

end;
