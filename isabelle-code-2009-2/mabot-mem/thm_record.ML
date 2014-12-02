signature THEORY_RECORD = 
sig
  datatype funspec = 
    FunSpec of (string * typ)  (* name and type of function *)
                * ((term * term) list); (* defining equations *)

  datatype T of ThyRecord of
    { ndtyp : TM_Data.named_dtyp list,
      fdef : funspec list
    };

  val add_named_dtyp : TM_Data.named_dtyp -> T -> T (* may have induced renaming of constructors *)
  val add_fspec : funspec -> T -> T (* may have induced renaming of function symbols *)

  

end;

structure ThyRecord =
struct
    datatype funspec = 
    FunSpec of (string * typ)  (* name and type of function *)
                * ((term * term) list); (* defining equations *)

  datatype T of ThyRecord of
    { ndtyp : TM_Data.named_dtyp list,
      fdef : funspec list
    };

  

  val add_named_dtyp : TM_Data.named_dtyp -> T -> T (* may have induced renaming of constructors *)
  val add_fspec : funspec -> T -> T (* may have induced renaming of function symbols *)



end;

local structure CheckThmRecord : THM_RECORD = ThmRecord; in val _ = () end;


signature THM_RECORD =
sig

  datatype T of ThmRecord of
    { thy_rec : ThyRecord.T,
      thm_term : term,
      proof : Pretty.T,
      name : string 
    };
  
  fun funspec_ord :  

  (* order: alpha-convertable upto constructor names, and function name.
     EQUAL => same datatype, same fundefs, and same term. It ignores proof and name.  
  *)
  val ord : T -> T -> order
  
  (* pretty ThmRecord in such a way that ML can parse it again as the same object *)
  val ml_pretty : T -> Pretty.T
  
  (* pretty print as we need it for online presentation *)
  val html_pretty : T -> Pretty.T

end;

structure ThmRecord
= struct 

datatype T of ThmRecord of
  { ndtyp : TM_Data.named_dtyp,
    fdef : (string * typ) * ((term * term) list),
    thm_term : term,
    proof : string,
    name : string 
  };

exception unimplemented_exp of unit  

fun ord (ThmRecord rep1) (ThmRecord rep2) : order = raise unimplemented_exp ();

fun ml_pretty_fdef ((s,ty),term_rws) : Pretty.T = raise unimplemented_exp ();
    
fun ml_pretty (ThmRecord rep) = 
    Pretty.chunks 
      [Pretty.str "ThmRecord {",
       Pretty.indent 2 (Pretty.chunks [
         Pretty.block [Pretty.str "ndtyp = ", NamedDType.ml_pretty (#ndtyp rep), Pretty.str ","],
         Pretty.block [Pretty.str "fdef = ", ml_pretty_fdef (#fdef rep), Pretty.str ","],
         Pretty.block [Pretty.str "thm_term = ", 
                       Pretty.str (Trm.MLSerialise.string_of_term (#thm_term rep)), 
                       Pretty.str ","],
         Pretty.block [Pretty.str ("proof = \"" ^ (#proof rep) ^ "\""), Pretty.str ","],
         Pretty.block [Pretty.str ("name = \"" ^ (#name rep) ^ "\""), Pretty.str ","],
       ],
       Pretty.str "}"];

fun html_pretty (ThmRecord rep) = Pretty.str "not yet implemented!";

end;

(* *)
local structure CheckThmRecord : THM_RECORD = ThmRecord; in val _ = () end;
