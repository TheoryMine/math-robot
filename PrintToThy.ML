


(* Code for printing TheoryMine datatypes,
   functions and theorems to Isabelle .thy files. *)

structure PrintToThy =
struct

fun elem_to_string isa_typs dtyp_nm e =
    case e of
      DataGen.Rec => "\""^ dtyp_nm ^ "\" "
    | (DataGen.Typ tn_nm) => "\""^ (fst (Tn.NTab.get isa_typs tn_nm)) ^"\" ";

fun elems_to_string isa_typs dtyp_nm elems =
    Library.implode_space " " (map (elem_to_string isa_typs dtyp_nm) elems)

fun constr_to_string isa_typs dtyp_nm (constr_nm, elems) =
      " \""^(Fn.dest constr_nm)^"\" " ^ (elems_to_string isa_typs dtyp_nm elems);

fun constrs_to_string isa_typs dtyp_nm [] = ""
  | constrs_to_string isa_typs dtyp_nm [constr] =
    constr_to_string isa_typs dtyp_nm constr
  | constrs_to_string isa_typs dtyp_nm (c::cs) =
    (constr_to_string  isa_typs dtyp_nm c) ^ "|"
    ^ constrs_to_string isa_typs dtyp_nm cs;

fun datatype_to_string ctxt dtyp =
  let
    val isa_typ_tab = TM_Data.DType.Ctxt.get_typs ctxt
    (*val (dtype_nm_str,_) = Tn.NTab.get isa_typ_tab dtyp *)
    val dtype_nm_str = Tn.dest dtyp
    val (NamedDType.Ndtyp dtyp_constrs) =
        TM_Data.DType.Ctxt.get_dtyp ctxt dtyp
    val constr_str = "datatype "^"\""^dtype_nm_str ^"\"" ^ " = " ^
                      (constrs_to_string isa_typ_tab dtype_nm_str
                                         (Fn.NTab.list_of dtyp_constrs)) ^"\n"
  in
    constr_str
  end;

(* GG code *)
fun term_to_str ctx v = (Print_Mode.setmp [] (fn () => Syntax.string_of_term ctx v) ())
fun typ_to_str ctx v = (Print_Mode.setmp [] (fn () => Syntax.string_of_typ ctx v) ())


fun string_of_fn ctxt =
  (* fixme: separation between matches is a bit funny *)
 let fun pretty_body [] =  []
      |  pretty_body (x::xs) =
           (Pretty.block [Pretty.str "  \"", Pretty.str (term_to_str ctxt x), Pretty.str "\""])
          :: ((map (fn tm => Pretty.block [Pretty.str "| \"",
                                            Pretty.str (term_to_str ctxt tm),
                                            Pretty.str "\""])
               xs));
     fun pretty_fn (nm,((nm', ty), trms)) =
        Pretty.chunks
          (  [ Pretty.block ([(Pretty.str ("fun "^ (Fn.NTab.string_of_name nm) ^" :: \"")),
                            Pretty.str (typ_to_str ctxt ty), Pretty.str "\" where"])]
           @ (pretty_body trms));
      fun pretty_fntab ctxt fntab =
             Pretty.chunks (map pretty_fn (Fn.NTab.list_of fntab));
      fun pretty_fns ctx =
         TM_Data.Fun.Ctxt.get_fntab ctxt  |> (pretty_fntab ctxt)
in
   Pretty.string_of (pretty_fns ctxt)
end;



fun string_of_dtyp_and_fnw ctxt dtyp =
    (string_of_dtyp ctxt dtyp) ^ "\n\n" ^ (string_of_fn ctxt);


end;
