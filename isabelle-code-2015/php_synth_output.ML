(* Takes a datatype, a function and a context and prints the
SynthOutput from the ctxt to a php file, assuming it contains the
result of synthesis on the given datatype and function *)

signature PHP_SYNTH_OUTPUT =
sig
val php_dtyp : Proof.context -> Tn.NTab.name -> string
val php_fun : Proof.context -> Fn.NTab.name -> string
val php_synth_thrms  : Proof.context -> string

(* Main function for outputting php *)
val phpify_theory : Proof.context -> Tn.name -> Fn.name -> unit

end;

structure DB_PHPSynthOutput =
struct

  fun php_dtyp ctxt dtyp_nm =
        (StringReformater.datatype_to_FO_string ctxt dtyp_nm)
        |> (StringReformater.stringterm_to_html);

  fun php_fun ctxt fname =
      let
        val (_,ty) = TM_Data.Fun.Ctxt.constinfo_of_fname ctxt fname
        val pretty_eqs = Fn.NTab.get (TM_Data.Fun.Ctxt.get_fntab ctxt) fname
                    |> snd |> map TM_Data.termpair_of_defining_eq
                    |> map (fn (l,r) =>
                    Pretty.block [
                      Pretty.str "<tr><td width=\"48%\" align=\"right\">\n  ",
                      Pretty.str (StringReformater.stringterm_to_html (StringReformater.term_to_FO_string l)),
                      Pretty.str "\n</td><td width=\"4%\" align=\"center\">=</td><td width=\"48%\" align=\"left\">\n  ",
                      Pretty.str (StringReformater.stringterm_to_html (StringReformater.term_to_FO_string r)),
                      Pretty.str "\n</td></tr>"])
                    |> Pretty.chunks;
      in
        (Pretty.string_of o Pretty.chunks)
          [Pretty.str "<table>",
           pretty_eqs,
           Pretty.str "</table>\n"]
      end;

fun php_synth_thrms ctxt =
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
fun phpify_theory ctxt dtyp_nm fname =
    Print_Mode.setmp [] (fn () =>
    let val (_,ty) = TM_Data.Fun.Ctxt.constinfo_of_fname ctxt fname
        val typtntab = TM_Data.DType.Ctxt.get_typtntab ctxt
        val all_tns =
             (Trm.atomic_typconsts_of_typ ty)
               |> map_filter (Symtab.lookup typtntab)
               |> Tn.NSet.of_list |> Tn.NSet.list_of(* removed dups *)
        val selected_tns = filter (TM_Data.DType.Ctxt.is_tm_rec_tn ctxt) all_tns
        val pretty =
            Pretty.chunks [
              Pretty.str "<?",
              Pretty.str "$theory = '<table><tr><td align=\"center\" width=\"100%\">",
              Pretty.indent 2 (Pretty.chunks
                (Pretty.separate "<br>" (map (Pretty.str o php_dtyp ctxt)
                  selected_tns))),
              Pretty.str "<br>\n<br>",
              Pretty.block [Pretty.str (StringReformater.stringterm_to_html (Fn.dest fname)),
                            Pretty.str " : ",
                            Pretty.str (StringReformater.stringterm_to_html
                              (StringReformater.string_of_typ ctxt ty))],
              Pretty.str "</td></tr></table>",
              Pretty.str (php_fun ctxt fname),
              Pretty.str "';\n",
              Pretty.str "$theorems = array();",
              Pretty.str (php_synth_thrms ctxt),
              Pretty.str "?>"
            ];
    in
      File_Util.writeStringToFilepath
        {path=("./output/"^(Tn.dest dtyp_nm)^"__"^(Fn.dest fname)^".php"),
         str=(Pretty.string_of pretty)}
    end) ();

end;

structure PHPSynthOutput : PHP_SYNTH_OUTPUT = DB_PHPSynthOutput;
