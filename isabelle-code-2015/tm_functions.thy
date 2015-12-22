theory tm_functions
imports "tm_datatypes"
begin


(* pretty printing in empty Print_Mode; for examining the PG *isabelle* buffer *)

ML {*
  fun pwriteln p = Print_Mode.setmp [] (fn () => Pretty.writeln (p ()));
  fun swriteln s = Print_Mode.setmp [] (fn () => Pretty.writeln (Pretty.str s)) ();
  (* pretty print exponentially few: pretty print 1 in 2^n *)
  fun mk_prettyf_exp_few pf = 
      let val i = Unsynchronized.ref 0;  val nth = Unsynchronized.ref 2; 
        fun prettyf x = 
            (i := (!i) + 1; (* print every nth function out*)
             if (Int.mod(!i,!nth) = 0) then (nth := (!nth) * 2; 
               Print_Mode.setmp [] (fn () => pf x i) (); ()) else ();
             x);
       in prettyf end;
*}

ML {*
(* construct function synthesis params for a level1 function (defined only in terms of datatype) 
   given context, type and number of args *)
fun level1_funparam_seq_of_datatype ctxt rec_tynm nargs =
    let val nset = (TM_Data.DType.Ctxt.get_tnset ctxt);
        val thy = (Proof_Context.theory_of ctxt);
        fun get_isa_typn tn = fst (Tn.NTab.get (TM_Data.DType.Ctxt.get_typs ctxt) tn);
        val cparams = 
            ConstraintParams.empty 
              |> ThyConstraintParams.add_eq ctxt (* IMPROVE: is this needed? *)
              |> ThyConstraintParams.add_datatype ctxt (get_isa_typn rec_tynm);
    in 
    (* Seq of element lists upto nargs + 1 (+1 to include result type) *)
      (DataGen.suc_seq (DataGen.nr_elem_list_suc' nset)
        (the (DataGen.nr_mk_bot_elem_list nset (nargs + 1))))
      |> Seq.map (map (fn DataGen.Typ x => x))
      |> Seq.map
         (fn (result_tynm::arg_tynms) =>
          TM_Data.FunParams {
            rec_tynm = rec_tynm, (* type this function is recursive on *)
            arg_tynms = arg_tynms, (* other arguments used *)
            result_tynm = result_tynm, (* result type *)
            cparams = cparams (* basic constraints *)
              |> ThyConstraintParams.add_datatypes ctxt (map get_isa_typn arg_tynms), (* add other constructors *) 
            size = 8
           })
    end;
*}

ML {*
fun pretty_synthd_func ctxt ((s, rec_tn, ty), eqs) = 
    Print_Mode.setmp [] (fn () => 
      Pretty.chunks
        [Pretty.str (StringReformater.fun_eqs_to_FO_spec_string ctxt eqs),
         Pretty.chunks  
           [Pretty.block [Pretty.str s, Pretty.str " := "],
            Pretty.indent 2 (Pretty.chunks (map (Trm.pretty ctxt) eqs))]
        ]) ();
*}

ML {*
(* construct all level1 functions for the given recursive type name, with nargs number of 
   arguments. *)
fun level1_function_seq_of_datatype ctxt rec_tynm nargs =
    let val nset = (TM_Data.DType.Ctxt.get_tnset ctxt);
        val thy = (Proof_Context.theory_of ctxt);
        val funparam_seq = level1_funparam_seq_of_datatype ctxt rec_tynm nargs;
        val prettyf = mk_prettyf_exp_few
            (fn x => fn i => Pretty.writeln (Pretty.chunks [(Pretty.str ("fun: " ^ (Int.toString (!i)) ^ ": ")),
                                              (pretty_synthd_func ctxt x)]))
    in 
      Seq.maps (fn p => Seq.of_list (map prettyf (TM_Data.synth_funs thy p)))
               funparam_seq
    end;
*}


(*  *)
ML {*
PolyML.print_depth 200;
val l = #descr (the (BNF_LFP_Compat.get_info @{theory} [] "Nat.nat"));
val [(a,(ty,x,[(zero_const,zero_args), (suc_const,suc_args)]))] = l;
*}

(*  *)
ML {*
  fun has_non_type_const t = 
      Library.exists
        (fn (s,ty) => List.exists (fn s2 => s = s2) base_const_names)
        (Trm.consts_of t);
*}

(*  *)
ML {*
 (* case Symtab.lookup (TM_Data.DType.Ctxt.get_typtntab ctxt) s
            of NONE => false
             | SOME tn => not (Tn.NTab.contains (TM_Data.DType.Ctxt.get_dtyps ctxt) tn) *)
*}

(* counter for number of well-defined functions generated *)
ML {*
  val total_count = Unsynchronized.ref 0;
  val goodn = Unsynchronized.ref 0;
  val ignoredn = Unsynchronized.ref 0;
*}


ML {*
  (* Extra sequence tools *)
  fun seq_fold f seq x = 
      (case Seq.pull seq of NONE => x
          | SOME (h,seq') => seq_fold f seq' (f h x));

  fun number_seq seq = 
      let val num = Unsynchronized.ref 0
      in Seq.map (fn x => (num := !num + 1; (!num,x))) seq end;
*}

ML{*
  datatype fun_synth_result = 
    Synthesised of Fn.name * theory
  | SynthBadFun of string * theory 
  | SynthBug of string 
  | SynthTrivial;
*}

ML {*
  (* function synthesis: function recursive on dn, 
     filtering 1 in filtern of the functions, offset by filteroffset. *)
  fun fun_synth (filteroffset,filtern) dn appfun thy = 
      let
        val _ = (goodn := 0; ignoredn := 0; total_count := 0)
        val nargs = 1; (* number of other (non-rec) arguments *)
        val funspec_seq = level1_function_seq_of_datatype @{context} dn nargs;
      in 
        seq_fold (fn (x as ((s,ty,rty),eqs)) => fn thy => 
                 let val result = 
                         (if (FastArgNeglect.syntactically_arg_neglecting_fundef eqs)
                             orelse (FastArgNeglect.pattern_arg_neglecting_fundef eqs)
                             orelse (List.all (not o has_non_type_const) eqs)
                          then SynthTrivial
                          else (let val (fnm, (err_opt, thy2)) = 
                                        TM_Data.add_new_function' Fn.default_name x thy
                                in if is_none err_opt then Synthesised(fnm,thy2)
                                   else SynthBadFun(the err_opt, thy2) end))
                          handle ERROR s => (SynthBug("ERROR exception: " ^ s))
                               | _ => (SynthBug("Unkown error total_count: " ^ (Int.toString (!total_count))))
                 in (total_count := !total_count +1; 
                     case result of 
                       Synthesised(fnm,thy2) => (goodn := !goodn + 1; appfun thy2 fnm; thy2)
                     | SynthBadFun(err_msg,thy2) => (ignoredn := !ignoredn + 1; writeln err_msg; thy2)
                     | SynthBug(err_msg) => (ignoredn := !ignoredn + 1; writeln err_msg; thy)
                     | SynthTrivial => (ignoredn := !ignoredn + 1; thy))
                 end)
              (* take only 1 in n of the functions, offset by filteroffset *)
              (filterseq_1_in_n (Unsynchronized.ref filteroffset) filtern funspec_seq)
              thy
      end;
*}


end