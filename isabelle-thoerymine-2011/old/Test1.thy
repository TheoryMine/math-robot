theory Test1
imports MakeFun
begin

ML{*
  (* Generate some left-hand sides *)
  val c_a = @{term "Ca"}
  val c_b = @{term "Cb"}
  val rec_typ = @{typ "mw"};
  val eq = @{term "op ="};
  (*val other_arg_types = [@{typ "nat"}, @{typ "bool"}]*)
    val other_arg_types = [rec_typ];
  val thy = @{theory}
  val ctxt = @{context};
*}

ML{*
  (*
    val funparams = MThy.FunParams{rec_tynm = rec_typ, arg_tynms = other_arg_types,
      res_tynm = rec_typ, avail_funs = MThy.Fn.NSet.empty,
      all_types = MThy.Tn.NSet.of_list [MThy.Tn.mk "mw"],thrms = [], size = 4}
  *)
*}


ML{*
(* A temporary name to use during synthesis *)
val tmp_funnm = "f";
val init_ConstInfo = 
IsaCoSy_SynthFundefs.init_const_infos_for_just 
      [(Term.dest_Const eq,[])]
      [rec_typ]
      []
      @{theory};

(* Synthesise function bodies of type mw  ==> mw ==> mw  *)
val all_fundefs =
  IsaCoSy_SynthFundefs.synth_fundef 
    ([c_a],[c_b],rec_typ) (* to recurse on this datatype *)
    other_arg_types (* with these other arguments *)
    rec_typ (* return type *)
    4 (* upto term size *)
    tmp_funnm (* Temporary function name *)
    @{theory} 
    init_ConstInfo
;

*}

(* print *)
ML{*
(* There's only one base and one recursive case for this datatype *)

map_index (fn (i,def_eqs) => 
  let val _ = writeln " --- "
  val _ = writeln ("Function "^Int.toString i)
  in
  map (fn eq => Trm.print ctxt eq) def_eqs
  end) all_fundefs

(*
writeln "\---";
writeln (Int.toString(length bases'));
writeln " : ";
map (Trm.print ctxt) bases';
writeln "\n --- \n";
writeln (Int.toString(length recs'));
writeln " : ";
map (Trm.print ctxt) recs';
writeln "\n --- \n"; 
*)
*}

(* ---- From here on it doesn't work anymore (just ignore what's below), 
        because you need the FunParam-datatype 
        to  add things to theory nowadays *)

ML {*
(* Continue the example, add the mwf-function to the theory. We pick the relevant terms from the lists 
   generated above. *)
(*val t1' = hd bases';
val (_::_::t2'::_) = recs';
*)
(* The constructors come out reverse (first rec, then base) at the moment *)
val [t2',t1'] = List.nth (all_fundefs,24)

val function_name = "mwf";

Trm.print ctxt t1';
Trm.print ctxt t2';
*}
 -- "add material world function to theory"



setup {* MFun.add_new_function thy "f" funtion_name [t1',t2'] *}

print_theorems

ML{*
(* Generate another function, which uses mwf that we just defined. This time, also allow use of 
   AND. *)

val andt = @{term "op &"};
val mwft = @{term "Test1.mwf"};
val rec_typ = @{typ "mw"};
val other_arg_types = [@{typ "bool"}];
val thy = @{theory};
val ctxt = @{context};

(* In reality we're gonna want to add more theorems about AND if we want to allow fun-synthesis
   to use it, but here's some examples of useful constraints *)
val and_thms = [@{thm "HOL.conj_absorb"}, @{thm "HOL.conj_left_absorb"}, @{thm "HOL.conj_commute"},
 @{thm "HOL.conj_assoc"}];

(* Generate a constInfo again. Think we have to start with a fresh one, as we've added a function.
   Because mwf is defined in this theory, IsaCoSy automatically picks up its defining functions 
   when it creates the ConstInfo. But we have to spearately give the theorms about AND (and_thrms).
*)
(*val init_ConstInfo = 
  ConstInfo.init_const_infos_for 
    [Term.dest_Const mwft, Term.dest_Const andt] 
    (map (fst o Term.dest_Type) (rec_typ::other_arg_types)) 
    and_thms 
    thy;
*)

(* Too many functions if we have and as well... *)
val init_ConstInfo =
  ConstInfo.init_const_infos_for 
    [Term.dest_Const mwft] 
    (map (fst o Term.dest_Type) (rec_typ::other_arg_types)) 
    [] thy;
*}
ML{*
(* Synthesise function bodies of type mw ==> bool ==> mw *)
val all_fundefs = 
  IsaCoSy_SynthFundefs.synth_fundef 
    ([c_a],[c_b],rec_typ) 
    other_arg_types 
    rec_typ 
    5
    thy 
    init_ConstInfo
;
(* There's only one base and one recursive case for this datatype *)


map_index (fn (i,def_eqs) => 
  let val _ = writeln " --- "
  val _ = writeln ("Function "^Int.toString i)
  in
  map (fn eq => Trm.print ctxt eq) def_eqs
  end) all_fundefs

(*
val bases' = flat bases;
val recs' = flat recs;

writeln "\n --- \n";
writeln (Int.toString(length bases'));
writeln " : ";
map (Trm.print ctxt) bases';
writeln "\n --- \n";
writeln (Int.toString(length recs'));
writeln " : ";
map (Trm.print ctxt) recs';
writeln "\n --- \n"; 
*)
*}

end;