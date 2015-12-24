theory "run_synth_debug"
imports "tm_synth"
begin


ML {*
Trm.MLSerialise.string_of_term @{term "x :: nat"};
*}

fun f :: "T_10 \<Rightarrow> nat \<Rightarrow> nat"
where 
  "f (C_20 a) b = b"  
| "f (C_19 a b) c = f a 0"

ML {*
val skip_first_n = 20
val funspec_seq =
        (level1_function_seq_of_datatype @{context} (Tn.mk "T_10") 1)
        |> number_seq
        |> Seq.chop skip_first_n
        |> snd
        |> Seq.take 10;

val SOME (funspec as (f_id,fundef), more) = Seq.pull funspec_seq;

val eqs = funspec |> snd |> snd;

false = (FastArgNeglect.syntactically_arg_neglecting_fundef eqs)
        orelse (FastArgNeglect.pattern_arg_neglecting_fundef eqs)
        orelse (List.all (not o has_non_type_const) eqs);
*}

ML {*
val (fname, (err_opt, thy2)) = TM_Data.add_new_function'
                              (Fn.mk ("f_" ^ (Int.toString f_id))) fundef @{theory}
*}

ML {*
val ctxt = Proof_Context.init_global thy2;
val (cparams,ctxt) = synth_isacosy_level1_theorems_for_fun fname ctxt;
*}

ML {* 
 val [rec_tn] = Tn.NSet.list_of (TM_Data.Fun.Ctxt.rectns_of_fname ctxt fname);
*}

ML {* 
  val (_,ty) = TM_Data.Fun.Ctxt.constinfo_of_fname ctxt fname
  val typtntab = TM_Data.DType.Ctxt.get_typtntab ctxt
  val all_tns = 
       (Trm.atomic_typconsts_of_typ ty)
         |> map_filter (Symtab.lookup typtntab) 
         |> Tn.NSet.of_list |> Tn.NSet.list_of(* removed dups *)
  val selected_tns = filter (TM_Data.DType.Ctxt.is_tm_rec_tn ctxt) all_tns;
  val thms = (SynthOutput.get_thms (SynthOutput.Ctxt.get ctxt))
  val (_,ty) = TM_Data.Fun.Ctxt.constinfo_of_fname ctxt fname
  val pretty_eqs = Fn.NTab.get (TM_Data.Fun.Ctxt.get_fntab ctxt) fname;
  val x = fname;
*}

ML {*
val (_,t::ts) = (pretty_eqs);
Trm.MLSerialise.string_of_term t;
*}

ML_file "prettification.ML"
ML_file "php_synth_output.ML"

ML {* 
val x= (map (Pretty.str o PHPSynthOutput.php_dtyp ctxt)
                  selected_tns);
*}

ML {*

val s = Pretty.string_of (Print_Mode.setmp [] (fn () => Pretty.str (StringReformater.string_of_typ ctxt ty)) ());
open StringReformater;
*}


ML {*
stringterm_to_html s;
*}

ML {*
val dtyp_nm = (Tn.mk "T_10");
val s = (PHPSynthOutput.php_fun ctxt fname)^(PHPSynthOutput.php_synth_thrms ctxt);
val pretty = Pretty.str s;
((Tn.dest dtyp_nm)^"_"^(Fn.dest fname)^".php");

File_Util.writeStringToFilepath
        {path="./"^((Tn.dest dtyp_nm)^"__"^(Fn.dest fname)^".php"),
         str=(Pretty.string_of pretty)}

*}

ML {* 

PHPSynthOutput.phpify_theory ctxt dtyp_nm fname;

*}

ML {*
*}

(* 

ML {*
val (goodn,
     ignoredn,
     badfunn,
     funerrorl,
     prferrorl) =
  run_synth (Tn.mk "T_10")
            (20,  (* skip first this many functions *)
             1,    (* generate this many new functions *)
             0, 1) (* Generate all functions (those indexes: 0 mod 1) *)
            1      (* one non-recursive argument for the generated functions *)
            @{theory};
*}

ML {*
tracing ("Good Functions: " ^ (Int.toString goodn));
tracing ("Ignored Functions: " ^ (Int.toString ignoredn));
tracing ("Bad Functions: " ^ (Int.toString badfunn));
tracing ("Fun Synth Errors: " ^ (Int.toString (length funerrorl)));
tracing ("Proof Synth Errors: " ^ (Int.toString (length prferrorl)));
tracing ("Synthesis completed.");
*}


ML {*
synth_and_save_thms_for_fun thy2 21 fname;
*}

ML {* 
*}
(* 
ML {*
synth_and_save_thms_for_fun thy2 21 fname;
*}

ML {* 
SynthOutput.Ctxt.get @{context}
*}


theorem "f a 0 = 0"
apply (tactic "DB_TM_Provers.ripple_meth")

apply (ripple_tac)
apply (induct "a")
apply simp
apply simp
done

end
