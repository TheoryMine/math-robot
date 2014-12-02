header{* An Isabelle-term representation of datatypes. *}
theory ACFilterDtyp 
imports TM_Data
begin

datatype type = Unit | Recursive | Typ string

axiomatization Plus :: "type => type => type" 
where plus_commute: "Plus a b = Plus b a"
  and plus_assoc: "Plus a (Plus b c) = Plus (Plus a b) c"


axiomatization Times :: "type => type => type"
where times_commute: "Times a b = Times b a"
  and times_assoc: "Times a (Times b c) = Times (Times a b) c" 

(* Additional datatypes we want to avoid: Binary Trees. *)

datatype 'a bin_tree = Leaf | Node "'a bin_tree" "'a" "'a bin_tree"
datatype 'a bin_tree2 = Leaf2 'a | Node2 "'a bin_tree2" "'a bin_tree2"
datatype 'a bin_tree3 = Leaf3 'a | Node3 "'a bin_tree3" "'a" "'a bin_tree3"

ML{*
signature  AC_FILTER_DTYP =
sig 
  (* The names of Isabelle datatypes we want to check against *) 
  val isabelle_datatype_names : string list

  val ndtyp_to_term : NamedDType.T -> term
  val dtyp_to_term : DataGen.dtyp -> term
  val isa_dtyp_to_term : Datatype_Aux.info -> term

  (* Given a new TheoryMine datatype, check if it AC-matches
     some known datatype. *)
  val ndtyp_is_ac_subsumed : NamedDType.T -> bool
  val dtyp_is_ac_subsumed : DataGen.dtyp -> bool
  
end


structure ACFilterDtyp : AC_FILTER_DTYP =
struct 

(* ---------------------------------------------*)
(* Generate a term from a TheoryMine datatype.  *)
(* ---------------------------------------------*)                     
fun elem_to_term e = 
    case e of 
      DataGen.Rec => @{term "ACFilterDtyp.Recursive"}
    | (DataGen.Typ nm) =>
      let 
      val tyname = Tn.NTab.string_of_name nm
      in @{term "ACFilterDtyp.Typ"}$(HOLogic.mk_string tyname) end;
    
fun elems_to_term [] = @{term "ACFilterDtyp.Unit"}
  | elems_to_term [e] = elem_to_term e
  | elems_to_term (e::es) = 
    let val ts = elems_to_term es 
    in @{term "ACFilterDtyp.Times"}$(elem_to_term e)$ts end;

fun ndtypll_to_term [] = raise ERROR "empty type"
  | ndtypll_to_term [(_,elems)] = elems_to_term elems
  | ndtypll_to_term ((_,elems)::cs) = 
    let val ts = ndtypll_to_term cs 
    in @{term "ACFilterDtyp.Plus"}$(elems_to_term elems)$ts end;  

fun dtypll_to_term [] = raise ERROR "empty type"
  | dtypll_to_term [elems] = elems_to_term elems
  | dtypll_to_term (elems::cs) = 
    let val ts = dtypll_to_term cs
    in @{term "ACFilterDtyp.Plus"}$(elems_to_term elems)$ts end;  

(* Assumes dtyp is of type NamedDType.T, which is a table indexed by constructor names 
   to DataGen.elem_typ lists. *)
fun ndtyp_to_term (NamedDType.Ndtyp dtyp) = 
    ndtypll_to_term (Fn.NTab.list_of dtyp);

fun dtyp_to_term (DataGen.DType constrs) = 
    dtypll_to_term constrs;

(* ---------------------------------------------*)
(* Generate a term from an Isabelle datatype.   *)
(* ---------------------------------------------*) 
fun isa_elem_to_term (descr,sorts) e =
    case e of
      Datatype_Aux.DtTFree nm => 
     Var((nm,0),@{typ "type"})
    | Datatype_Aux.DtType (nm, dtyps) =>
      let val typnm =
              (Datatype_Aux.DtType (nm, dtyps))
              |> Datatype_Aux.typ_of_dtyp descr sorts
              |> Datatype_Aux.name_of_typ
      in
        @{term "Typ"}$Var((typnm,0),@{typ "string"})
      end
    | Datatype_Aux.DtRec i => @{term "Recursive"};

(* Translate an Isabelle datatype to our term-representation *)
fun isa_elems_to_term (descr, sorts) [] = @{term "Unit"}
  | isa_elems_to_term (descr, sorts) [e] = isa_elem_to_term (descr, sorts) e
  | isa_elems_to_term (descr, sorts) (e::es) = 
    let val ts = isa_elems_to_term (descr, sorts) es 
    in @{term "Times"}$(isa_elem_to_term (descr,sorts) e)$ts end;

fun isa_constr_dtyps_to_term (descr, sorts) ([]) = raise ERROR "empty type"
    | isa_constr_dtyps_to_term (descr, sorts) ([(_,elems)]) = 
      isa_elems_to_term (descr, sorts) elems
    | isa_constr_dtyps_to_term (descr, sorts) ((_,elems)::cs) =
      let 
        val ts = isa_constr_dtyps_to_term (descr, sorts) cs
        val els = isa_elems_to_term (descr, sorts) elems  
      in @{term "Plus"}$els$ts end;  
                                  
(* Make one of our terms from an Isabelle datatype *)
fun isa_dtyp_to_term dinfo =
    let 
      val sorts = (#sorts dinfo)
      val descr = (#descr dinfo)
      (*A list of Isabelle-dtyps, as (string, dtyp list) pairs*)
      val dtyp_constrs = 
          maps (fn (_,(_,_, constructors)) => constructors) descr
    in
      isa_constr_dtyps_to_term (descr,sorts) dtyp_constrs
    end;



(* ----------------------------------------------*)
(* Test a datatype for AC-equality against known *)
(*  datatypes.                                   *)
(* ----------------------------------------------*) 

(* Tables storing the facts that the 'Plus' and 
   'Times' combinators we build the term 
   representation of our datatypes from are AC. *)
val com_tab = Commfun.emptyCTab 
  |> Commfun.add_comm_thm @{thm "ACFilterDtyp.plus_commute"}
  |> Commfun.add_comm_thm @{thm "ACFilterDtyp.times_commute"};

val assc_tab = Commfun.emptyATab
  |> Commfun.add_ass_thm @{thm "ACFilterDtyp.plus_assoc"}
  |> Commfun.add_ass_thm @{thm "ACFilterDtyp.times_assoc"};

(* Think: We probably don't want to include ALL datatypes,
   some that exist in Isabelle become very general terms,
   subsuming all our datatypes. *)

(* Current Isabelle datypes we check against *)
val isabelle_datatype_names = ["List.list", "nat", "ACFilterDtyp.bin_tree", "ACFilterDtyp.bin_tree2", "ACFilterDtyp.bin_tree3"]; 

val isabelle_datatype_terms = 
    map (isa_dtyp_to_term o ThyConstraintParams.get_dinfo_in_thy @{theory}) 
        isabelle_datatype_names;

(* This checks a TheoryMine datatype for AC equivalens agains
   the 'isabelle_datatypes', given above *)
fun ndtyp_is_ac_subsumed dtyp = 
   let val dtyp_trm = ndtyp_to_term dtyp
   in Library.exists 
        (fn isa_t => (Commfun.eq_isa_trms assc_tab com_tab isa_t dtyp_trm))
        isabelle_datatype_terms
   end;

(* check is a DataGen datatype representation is subsumed by the isabelle ones *)
fun dtyp_is_ac_subsumed dtyp = 
   let val dtyp_trm = dtyp_to_term dtyp
   in Library.exists 
        (fn isa_t => (Commfun.eq_isa_trms assc_tab com_tab isa_t dtyp_trm))
        isabelle_datatype_terms
   end;

end; (*struct *)
*}


end