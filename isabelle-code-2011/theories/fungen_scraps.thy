
ML {* 
val thy = @{theory};

val (proj_fs,maybe_proj_fs,non_proj_fs) =
    Fn.NTab.fold 
      (fn (fname,(x as (c,ty),eqs)) => fn (proj_fs,maybe_proj_fs,non_proj_fs) => 
       let (* prepare the proof tool(s) *)
          val thms1 = TM_Data.Fun.Thy.defthms_of_fname thy fname;
          val thms2 = TM_Data.Fun.Thy.ripple_thms_of_term thy fname;
          val prepared_thy = 
           thy |> Context.theory_map (WRulesGCtxt.init NONE)
               |> fold (Context.theory_map o WRulesGCtxt.add_wrule_thm) thms;
         val proj_infos = Seq.list_of (DB_Def_Utils.neglects_argument_raw 
               (ProofContext.init_global prepared_thy) ripple_meth_text 5 5 (Const x));
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
*)


