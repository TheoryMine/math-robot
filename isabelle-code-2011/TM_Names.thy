header{* Isabelle code to synthesise function definitions in ML *}
theory TM_Names 
imports Main IsaP
begin

-- "Name structures"
ML{*
(* TheoryMine Types: the data structures/types used in TheoryMine and the
   mechanisms to create new datatype *)
signature TM_TYPES =
sig
  (* function names (constructors and functions) *)
  structure Fn : sig include SSTR_NAMES; val default_constr_name : name end
  (* type names: elements/arguments in a constructor *)
  structure Tn : SSTR_NAMES 
  (* names for variables *)
  structure Vn : SSTR_NAMES

  (* Constant to Type-name it is a constructor for: (f,t) = f is a constructor for type t *)
  structure FnTnMap : NAME_MAP 
    sharing FnTnMap.Sharing.Dom = Fn.Sharing
    sharing FnTnMap.Sharing.Cod = Tn.Sharing

  (* Type and Function relation: (t,f) = type of f involves t *)
  structure TnFnRel : NAME_BINREL
    sharing TnFnRel.Sharing.Dom = Tn.Sharing
    sharing TnFnRel.Sharing.Cod = Fn.Sharing

  (* Functions to Fucntions they are used in map: (f1,f2) = f1 definition involves f2 *)
  structure FnRel : NAME_BINREL
    sharing FnRel.Sharing.Dom = Fn.Sharing
    sharing FnRel.Sharing.Cod = Fn.Sharing
end;

functor TM_Types(N : SSTR_NAMES) : TM_TYPES = 
struct
  structure NMap = NameMapFun(structure Dom = N and Cod = N);
  structure NRel = NameBRelFun(structure Dom = N and Cod = N);
  (* constructor names *)
  structure Fn : sig include SSTR_NAMES; val default_constr_name : name end 
    = struct open N; 
        val default_name = N.mk "f_1"; 
        val default_constr_name = N.mk "C_1"; 
      end;
  (* type names: elements/arguments in a constructor *)
  structure Tn : SSTR_NAMES = struct open N; val default_name = N.mk "T_1"; end;
  (* names for variables *)
  structure Vn : SSTR_NAMES = struct open N; val default_name = N.mk "x_1"; end;
  structure FnTnMap = NMap;
  structure TnFnRel = NRel;
  structure FnRel = NRel;
end;
*}

text {* Construct the basic types *}
ML {* 
local structure TM_Types :> TM_TYPES = TM_Types(SStrName); in open TM_Types; end;
*}

end;
