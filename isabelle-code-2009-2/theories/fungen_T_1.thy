theory "fungen_T_1"
imports "../tm_datatypes" "../tm_functions"
begin

ML {*
  (* all type name set of current context *)
  val nset = (TM_Data.DType.Ctxt.get_tnset @{context});
  
  (* type names we know we can recurse on because we constructed them *)
  val rnset = TM_Data.DType.Ctxt.get_ctnset @{context}; 
  val SOME rec_tynm0 = Tn.NSet.get_first rnset;
  val SOME rec_tynm1 = Tn.NSet.next_bigger rnset rec_tynm0;
*}
ML {* TM_Data.DType.Ctxt.print_dtyp @{context} rec_tynm1; *}

ML {*
  fun ptracing p = Print_Mode.setmp [] (fn () => Pretty.writeln p) ();
  fun stracing s = Print_Mode.setmp [] (fn () => Pretty.writeln (Pretty.str s)) ();
*}

ML {*
  val sq = Print_Mode.setmp [] (fn () => 
      Seq.list_of (level1_function_seq_of_datatype @{context} rec_tynm1 1)) ();
  val x = length sq;
*}

ML {* TM_Data.DType.Ctxt.print @{context}; *}

ML {*
  (* counter for number of well-defined functions generated *)
  val goodn = ref 0;
  val trivn = ref 0;
*}

ML{*
  
*}

-- "Generate Functions"
setup {*
  fold (fn (x as ((s,ty,rty),eqs)) => fn thy => 
             let val ctxt = @{context};
                 val _ = ptracing (pretty_synthd_func ctxt x)
                 (* val _ = ptracing (Pretty.chunks (Pretty.separate "\n*****\n" (map (Pretty.str o Trm.MLSerialise.string_of_term) eqs))); *)
                 val (err_opt, thy2) = 
                     if (FastArgNeglect.syntactically_arg_neglecting_fundef eqs)
                     then (trivn := !trivn + 1; (NONE, thy))
                     else (TM_Data.add_new_function' Fn.default_name x thy)
                 val _ = if is_none err_opt then goodn := (!goodn) + 1  else ()
                 val _ = (ptracing o Pretty.str)
                          (case err_opt of NONE => "good fun: " ^ Int.toString (!goodn) 
                              | SOME m => "bad fun: " ^ m)
             in thy2 end handle ERROR s => 
               ((ptracing o Pretty.str) s; thy))
           (filter_1_in_n (ref 0) 200 sq) (* take only 1 in n of the functions... *)
*}

ML {* 
  (ptracing o Pretty.str) ("well-defined functions synthesised: " ^ Int.toString (!goodn));
  (ptracing o Pretty.str) ("triv argument neglecting ignored: " ^ Int.toString (!trivn));
*}

ML {* TM_Data.Fun.Ctxt.print @{context} *}

ML {*
val fntab = TM_Data.Fun.Ctxt.get_fntab @{context};
val ((proj_fs,maybe_proj_fs,non_proj_fs)) =
    Fn.NTab.fold 
      (fn (fname,(x as (c,ty),eqs)) => fn (proj_fs,maybe_proj_fs,non_proj_fs) => 
       let (* prepare the proof tool(s) *)
         val proj_infos = Seq.list_of (DB_Def_Utils.neglects_argument_raw 
                                         @{context} TM_Provers.ripple_meth_text 5 5 (Const x));
       in
        case map_filter (fn (t,SOME thm) => SOME thm | _ => NONE) proj_infos
          of [] => (case map_filter (fn (t,NONE) => SOME t | _ => NONE) proj_infos 
                      of [] => (proj_fs,maybe_proj_fs,fname::non_proj_fs)
                       | l => (proj_fs,(fname,l)::maybe_proj_fs,non_proj_fs))
           | l => ((fname,l)::proj_fs,maybe_proj_fs,non_proj_fs)
       end)
       fntab
       ([],[],[]);
*}

ML {*
  val xresults = (proj_fs,maybe_proj_fs,non_proj_fs)
*}

ML {* TM_Data.DType.Ctxt.print_dtyp @{context} rec_tynm1; *}

ML {* TM_Data.Fun.Ctxt.print @{context} ; *}



(* 
val ((proj_fs,maybe_proj_fs,non_proj_fs)) =
    Fn.NTab.fold 
      (fn (fname,(x as (c,ty),eqs)) => fn (proj_fs,maybe_proj_fs,non_proj_fs) => 
       let val proj_infos = Seq.list_of (DB_Def_Utils.neglects_argument_raw 
               (ProofContext.init_global thy) induct_auto_meth_text 5 5 (Const x));
       in
        case map_filter (fn (t,SOME thm) => SOME thm | _ => NONE) proj_infos
          of [] => (case map_filter (fn (t,NONE) => SOME t | _ => NONE) proj_infos 
                      of [] => (proj_fs,maybe_proj_fs,fname::non_proj_fs)
                       | l => (proj_fs,(fname,l)::maybe_proj_fs,non_proj_fs))
           | l => ((fname,l)::proj_fs,maybe_proj_fs,non_proj_fs)
       end)
       fntab
       ([],[],[]);
*)

end;
