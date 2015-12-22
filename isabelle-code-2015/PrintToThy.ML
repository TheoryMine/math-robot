


(* Code for printing TheoryMine datatypes, functions and theorems to Isabelle .thy files. *)

structure PrintToThy =
struct
 
fun mk_header dtyp_thy_nm = "theory "^dtyp_thy_nm^ "\n"^"imports TM_Data"^"\n"^"begin\n\n";
val eof = "\nend;"


(* Writes the actual file, contents are in thy_str. *)
(* return true if we have written the file, false if someone else has
already started it. *)
fun write_thy_file dtyp_file_nm thy_str =
    let
      fun safe_isDir s = 
          (OS.FileSys.isDir s) handle OS.SysErr _ => false;
      fun safe_mkDir s = 
          (if safe_isDir s then () else 
           OS.FileSys.mkDir s) handle OS.SysErr _ => ();
      (* CHECK PATH is correct *)    
      val path = "./tm_initial/theories/"

      val loc = path ^ dtyp_file_nm ^ ".thy"
      val _ = safe_mkDir path; 
    in
       ((OS.FileSys.fileId loc; false) handle 
       OS.SysErr _ => (let val outs = TextIO.openOut loc in 
                         TextIO.output (outs, thy_str); 
                       TextIO.closeOut outs; true end))
    end;

fun elem_to_string dtyp_nm isa_typs e =
    case e of 
      DataGen.Rec => "\""^ dtyp_nm ^ "\" " 
    | (DataGen.Typ tn_nm) => "\""^ (fst (Tn.NTab.get isa_typs tn_nm)) ^"\" ";
 
fun elems_to_string isa_typs dtyp_nm [] = " "
  | elems_to_string isa_typs dtyp_nm (e::es) = 
    (case e of 
      DataGen.Rec => "\""^ dtyp_nm ^ "\" "^ (elems_to_string isa_typs dtyp_nm es)
    | DataGen.Typ tn_nm => "\""^ (fst(Tn.NTab.get isa_typs tn_nm)) ^
                           "\" " ^ (elems_to_string isa_typs dtyp_nm es)
    );
 
fun constr_to_string isa_typs dtyp_nm (constr_nm, elems) =
      " \""^(Fn.dest constr_nm)^"\" " ^ (elems_to_string isa_typs dtyp_nm elems);

fun constrs_to_string isa_typs dtyp_nm [] = ""
  | constrs_to_string isa_typs dtyp_nm [constr] = 
    constr_to_string isa_typs dtyp_nm constr
  | constrs_to_string isa_typs dtyp_nm (c::cs) =
    (constr_to_string  isa_typs dtyp_nm c) ^ "|" 
    ^ constrs_to_string isa_typs dtyp_nm cs;

fun print_tm_dtyp_to_thy ctxt dtyp =
    let       
      val isa_typ_tab = TM_Data.DType.Ctxt.get_typs ctxt
      (*val (dtype_nm_str,_) = Tn.NTab.get isa_typ_tab dtyp *)
      val dtype_nm_str = Tn.dest dtyp          
      val dtyp_thy_name = "dtyp-"^dtype_nm_str
      val (NamedDType.Ndtyp dtyp_constrs) =  TM_Data.DType.Ctxt.get_dtyp ctxt dtyp
      val constr_str = "datatype "^"\""^dtype_nm_str ^"\"" ^ " = " ^ 
                        (constrs_to_string isa_typ_tab dtype_nm_str
                                           (Fn.NTab.list_of dtyp_constrs)) ^"\n"
      val output_str = (mk_header dtyp_thy_name) ^ constr_str ^ eof
    in
      write_thy_file dtyp_thy_name output_str
      
    end;

(* GG code *)

fun term_to_str ctx v = (Print_Mode.setmp [] (fn () => Syntax.string_of_term ctx v) ())
fun typ_to_str ctx v = (Print_Mode.setmp [] (fn () => Syntax.string_of_typ ctx v) ())


fun string_of_dtyp ctxt dtyp =
    let       
      val isa_typ_tab = TM_Data.DType.Ctxt.get_typs ctxt
      (*val (dtype_nm_str,_) = Tn.NTab.get isa_typ_tab dtyp *)
      val dtype_nm_str = Tn.dest dtyp          
      val dtyp_thy_name = "dtyp-"^dtype_nm_str
      val (NamedDType.Ndtyp dtyp_constrs) =  TM_Data.DType.Ctxt.get_dtyp ctxt dtyp
      val constr_str = "datatype "^"\""^dtype_nm_str ^"\"" ^ " = " ^ 
                        (constrs_to_string isa_typ_tab dtype_nm_str
                                           (Fn.NTab.list_of dtyp_constrs)) ^"\n"
    in
      constr_str
    end;

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
