(* Takes a datatype, a function and a context and prints the
SynthOutput from the ctxt to a php file, assuming it contains the
result of synthesis on the given datatype and function *)

signature SYNTH_STRING_OUTPUT =
sig
  val pretty_dtyp : Proof.context -> Tn.NTab.name -> Pretty.T
  val pretty_function : Proof.context -> Fn.NTab.name -> Pretty.T
  (* val pretty_theorems : Proof.context -> Pretty.T *)
  val pretty_theory : Proof.context -> Tn.name -> Fn.name -> Pretty.T
end;

structure Synth_To_Isathy =
struct

fun elem_to_str isa_typs dtyp_nm e =
    case e of
      DataGen.Rec => "\""^ dtyp_nm ^ "\" "
    | (DataGen.Typ tn_nm) => "\""^ (fst (Tn.NTab.get isa_typs tn_nm)) ^"\" ";

fun elems_to_str isa_typs dtyp_nm elems =
    space_implode " " (map (elem_to_str isa_typs dtyp_nm) elems)

fun constr_to_str isa_typs dtyp_nm (constr_nm, elems) =
      " \""^(Fn.dest constr_nm)^"\" " ^ (elems_to_str isa_typs dtyp_nm elems);

fun constrs_to_str isa_typs dtyp_nm [] = ""
  | constrs_to_str isa_typs dtyp_nm [constr] =
    constr_to_str isa_typs dtyp_nm constr
  | constrs_to_str isa_typs dtyp_nm (c::cs) =
    (constr_to_str isa_typs dtyp_nm c) ^ "|"
    ^ (constrs_to_str isa_typs dtyp_nm cs);

fun pretty_dtyp ctxt dtyp_nm =
  let
    val isa_typ_tab = TM_Data.DType.Ctxt.get_typs ctxt
    (*val (dtype_nm_str,_) = Tn.NTab.get isa_typ_tab dtyp *)
    val dtype_nm_str = Tn.dest dtyp_nm
    val (NamedDType.Ndtyp dtyp_constrs) =
        TM_Data.DType.Ctxt.get_dtyp ctxt dtyp_nm
    val constr_str = "datatype \"" ^ dtype_nm_str ^"\" = " ^
                      (constrs_to_str isa_typ_tab dtype_nm_str
                                         (Fn.NTab.list_of dtyp_constrs)) ^"\n"
  in
    Pretty.str constr_str
  end;

fun pretty_term ctx v = (Print_Mode.setmp [] (fn () => Syntax.pretty_term ctx v) ())
fun pretty_typ ctx v = (Print_Mode.setmp [] (fn () => Syntax.pretty_typ ctx v) ())

fun pretty_function ctxt fname =
  let
    fun pretty_body [] =  []
      | pretty_body (x::xs) =
          (Pretty.block [Pretty.str "  \"",
            pretty_term ctxt x, Pretty.str "\""])
          :: ((map (fn tm => Pretty.block [Pretty.str "| \"",
                                           pretty_term ctxt tm,
                                           Pretty.str "\""])
               xs));

    fun pretty_fn nm ((nm', ty), trms) =
        Pretty.chunks
          ([Pretty.block
            ([Pretty.str ("fun "^(Fn.NTab.string_of_name nm) ^" :: \""),
              pretty_typ ctxt ty, Pretty.str "\" where"])]
           @ (pretty_body trms));
  in
    pretty_fn fname (Fn.NTab.get (TM_Data.Fun.Ctxt.get_fntab ctxt) fname)
  end;

fun pretty_theorems ctxt =
    let
      fun phpify_prf prf = "'" ^ prf ^ "'";
      fun phpify_thm thm =
          "'" ^
          ((StringReformater.stringterm_to_html
            o StringReformater.term_to_FO_string
            o HOLogic.dest_Trueprop
            o Trm.change_vars_to_fresh_frees
            o Thm.prop_of) thm)
           ^ "'";
    in
      fold (fn (prf,thm) => fn outstr =>
              outstr
              ^ "array_push($theorems,\n"
              ^ "           array('proof' => "
              ^ (phpify_prf prf) ^",\n"
              ^ "                 'statement' => "
              ^ (phpify_thm thm) ^ "));\n"
          ) (SynthOutput.get_thms (SynthOutput.Ctxt.get ctxt)) ""
    end;

(*   (OS.FileSys.fileId loc; false) handle
       OS.SysErr _ => *)
(* i : int = global number id of function, used for filename *)
fun pretty_theory ctxt dtyp_nm fname =
    Print_Mode.setmp [] (fn () =>
    let
        val theoryName = (Tn.dest dtyp_nm)^(Fn.dest fname);
        val (_,ty) = TM_Data.Fun.Ctxt.constinfo_of_fname ctxt fname
        val typtntab = TM_Data.DType.Ctxt.get_typtntab ctxt
        val all_tns =
             (Trm.atomic_typconsts_of_typ ty)
               |> map_filter (Symtab.lookup typtntab)
               |> Tn.NSet.of_list |> Tn.NSet.list_of(* removed dups *)
        val selected_tns = filter (TM_Data.DType.Ctxt.is_tm_rec_tn ctxt) all_tns
    in
      Pretty.chunks [
        Pretty.str ("theory " ^ theoryName),
        Pretty.str "imports 'HOL-IsaPlannerSession'",
        Pretty.str "begin",
        Pretty.str "",
        Pretty.str "end"
      ]
    end) ();

(* in
      File_Util.writeStringToFilepath
        {path=(theoryName^".thy"),
         str=(Pretty.string_of pretty)}
    end) ();
*)
end;

local 
structure TypeCheck : SYNTH_STRING_OUTPUT = Synth_To_Isathy;
in val _ = (); end
