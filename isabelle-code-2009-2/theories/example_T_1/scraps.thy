
ML {*
  (* side effect: write results to file. *)
  
*}

.

ML {* 

OS.FileSys.isDir
val results = [];

(* FIXME: select only non-proj functions? *)
val fnames = (map fst (Fn.NTab.list_of (TM_Data.Fun.Ctxt.get_fntab @{context})))


val results =
   fold
     (synth_and_print @{theory})
     fnames
     results;
*}


ML {* 
  val outdir = "output";
*}

ML {*
  fun safe_isDir s = 
    (OS.FileSys.isDir s) handle OS.SysErr _ => false;
  fun safe_mkDir s = 
    (if safe_isDir s then () else 
     OS.FileSys.mkDir s) handle OS.SysErr _ => ();

  fun synth_and_print ctxt0 n a = 
      let
        val start_time = start_timing ();
        val (cparams,ctxt) = synth_isacosy_level1_theorems_for_fun n ctxt0;
        val end_time = end_timing start_time;

        val (lemmas,thms) = thms_of_synth_context ctxt;

        val _ = safe_mkDir outdir;
        val out = TextIO.openOut ("output/" ^ (Context.theory_name thy) ^ ".txt");
        fun pretty_term t = Trm.pretty ctxt t;
        fun writelnout p = TextIO.output (out, (Print_Mode.setmp [] (fn () => (Pretty.string_of p)) ()) ^ "\n");
        val _ = TextIO.output (out,"Time: " ^ (#message end_time) ^ "\n");
        val _ = TextIO.output (out,"Theorems: \n");
        val _ = thms 
                  |> map (fn (prf,thm) => 
                      Pretty.chunks 
                        [Pretty.block [Pretty.str "thm: ", Display.pretty_thm thm]]
                  |> map writelnout
        val _ = TextIO.output (out,"\n\n\n ***** \n");
        val _ = TextIO.output (out,"Conjectures: ");
        val _ = map (writelnout o pretty_term o fst) conjs;
        val _ = TextIO.flushOut out;
        val _ = TextIO.closeOut out;
      in
        (n,(#elapsed end_time,(conjs,thms)))::a
      end;
*}

ML {* 
val results = [];

(* FIXME: select only non-proj functions? *)
val fnames = (map fst (Fn.NTab.list_of (TM_Data.Fun.Ctxt.get_fntab @{context})))


val results =
   fold
     (synth_and_print @{theory})
     fnames
     results;
*}

 
.

ML {*
val ((thy_constraints',thy'),(conjs,thms)) = 
            synth_isacosy_level1_theorems_for_fun (Fn.mk "f_1") @{theory};
*}

(* 
ML {*
structure a = TM_Data.DType
*}

ML {*
structure a = TM_Data.DType.Ctxt
*}

ML {* 
  val NamedDType.Ndtyp ntab = TM_Data.DType.Ctxt.get_dtyp @{context} (Tn.mk "T_1");
  val l = Fn.NTab.list_of ntab;

  StringReformater.stringterm_to_html
  (Pretty.string_of 
   (Pretty.block (Pretty.separate " |" (map (fn (n,el) => Fn.pretty_name n) l))));
*}

ML {*TM_Data.DType.ThyData.get @{theory} *}

ML {* r *}
*)
