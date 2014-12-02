
ML {* TM_Data.DType.Ctxt.print_dtyp @{context} (Tn.mk "T_1"); *}
ML {*
 val simp_thms = the (#simps (Function.get_info @{context} @{term "f_1"})); 
*}
term "f_1"
term "C_1"
term "C_2"

ML {* 
  val x = start_timing ()  
*}
ML {* 
  fun timeit f x = 
      let val t = start_timing () val y = f x val t2 = end_timing t in 
        (Pretty.writeln (Pretty.block [Pretty.str (#message t2)]); y)
      end
*}
ML {* 
  val y = end_timing x
*}
  

ML {*
  val ((thy_constraints',thy'),(conjs,thms)) = 
      timeit (synth_level1_theorems_for_fun (Fn.mk "f_1")) @{theory};
*}
-- "Print synthesised conjectures"
ML{*
 val _ = map (Trm.print @{context} o fst) thms;
  Pretty.writeln (Pretty.str "---");
  val _ = map (Trm.print @{context} o fst) conjs;
*}
text {*
  f_1 a b = b 
  ---
*}


 ML {*
  val ((thy_constraints',thy'),(conjs,thms)) = 
      timeit (synth_level1_theorems_for_fun (Fn.mk "f_9")) @{theory};
*}
-- "Print synthesised conjectures"
ML{*
 val _ = map (Trm.print @{context} o fst) thms;
  Pretty.writeln (Pretty.str "---");
  val _ = map (Trm.print @{context} o fst) conjs;
*}
text {* 
 f_9 a (C_2 b c) = f_9 a b 
 f_9 a (f_9 b c) = f_9 a b 
 f_9 a (f_9 b c) = f_9 a c 
 f_9 a (C_1 b c) = f_9 a (C_1 b b) 
 f_9 a (C_1 b c) = f_9 a (C_1 c b) 
 f_9 a (C_1 b c) = f_9 a (C_1 c c) 
 f_9 (f_9 a b) c = f_9 (f_9 a a) a 
 f_9 (f_9 a b) c = f_9 (f_9 a a) b 
 f_9 (f_9 a b) c = f_9 (f_9 a a) c 
 f_9 (f_9 a b) c = f_9 (f_9 a b) a 
 f_9 (f_9 a b) c = f_9 (f_9 a b) b 
 f_9 (f_9 a b) c = f_9 (f_9 a c) a 
 f_9 (f_9 a b) c = f_9 (f_9 a c) b 
 f_9 (f_9 a b) c = f_9 (f_9 a c) c 
 f_9 (f_9 (f_9 a b) c) a = f_9 a a 
 f_9 (f_9 (f_9 a b) c) a = f_9 a b 
 f_9 (f_9 (f_9 a b) c) b = f_9 a a 
 f_9 (f_9 (f_9 a b) c) c = f_9 a a 
 f_9 (f_9 (f_9 a b) c) c = f_9 a b 
 f_9 (f_9 (f_9 a b) a) c = f_9 a a 
 f_9 (f_9 (f_9 a b) a) c = f_9 a b 
 f_9 (f_9 (f_9 a a) b) c = f_9 a a 
 --- 
 f_9 a b = f_9 a a 
 f_9 (f_9 (f_9 a b) c) a = f_9 a c 
 f_9 (f_9 (f_9 a b) c) b = f_9 a b 
 f_9 (f_9 (f_9 a b) c) b = f_9 a c 
 f_9 (f_9 (f_9 a b) c) c = f_9 a c 
 f_9 (f_9 (f_9 a b) a) c = f_9 a c 
 f_9 (f_9 (f_9 a b) b) c = f_9 a a 
 f_9 (f_9 (f_9 a b) b) c = f_9 a b 
 f_9 (f_9 (f_9 a b) b) c = f_9 a c 
 f_9 (f_9 (f_9 a a) b) c = f_9 a b 
 f_9 (f_9 (f_9 a a) b) c = f_9 a c 
*}



-- "Synthesise equality conjectures"
ML {*
  val ((thy_constraints',thy'),(conjs,thms)) = 
      timeit (synth_level1_theorems_for_fun (Fn.mk "f_2")) @{theory};
*}

-- "Print synthesised conjectures"
ML{*     
 val _ = map (Trm.print @{context} o fst) thms;
  Pretty.writeln (Pretty.str "---");
  val _ = map (Trm.print @{context} o fst) conjs;
*}
text {* 
 f_2 a b = f_2 a a 
 f_2 (f_2 a b) c = f_2 a b 
 --- 
 f_2 a (C_2 b c) = f_2 a b 
 f_2 (f_2 a b) c = f_2 a a 
 f_2 (f_2 a b) c = f_2 a c 
 f_2 a (C_1 b c) = f_2 a (C_1 b b) 
 f_2 a (C_1 b c) = f_2 a (C_1 c b) 
 f_2 a (C_1 b c) = f_2 a (C_1 c c) 
 f_2 a (C_1 b c) = f_2 a (C_2 a b) 
 f_2 a (C_1 b c) = f_2 a (C_2 a c) 
 f_2 a (C_2 b c) = f_2 a (C_1 c c) 
 f_2 a (C_2 b c) = f_2 a (C_2 a c) 
 f_2 a (C_2 (C_2 b c) c) = f_2 a b 
 f_2 a (C_2 (f_2 b a) c) = f_2 a b 
 f_2 a (C_2 (f_2 b b) c) = f_2 a b 
 f_2 a (C_2 (f_2 a b) c) = f_2 a b 
*}

.


ML {*
  val ((thy_constraints',thy'),(conjs,thms)) = 
      timeit (synth_level1_theorems_for_fun (Fn.mk "f_3")) @{theory};
*}
-- "Print synthesised conjectures"
ML{*
 val _ = map (Trm.print @{context} o fst) thms;
  Pretty.writeln (Pretty.str "---");
  val _ = map (Trm.print @{context} o fst) conjs;
*}
text {*
--- 
 f_3 a (f_3 b b) = f_3 a (f_3 b a) 
 f_3 (f_3 a b) c = f_3 (f_3 a b) a 
 f_3 (f_3 a b) c = f_3 (f_3 a b) b 
*}
.

ML {*
  val ((thy_constraints',thy'),(conjs,thms)) = 
      timeit (synth_level1_theorems_for_fun (Fn.mk "f_4")) @{theory};
*}
-- "Print synthesised conjectures"
ML{*
 val _ = map (Trm.print @{context} o fst) thms;
  Pretty.writeln (Pretty.str "---");
  val _ = map (Trm.print @{context} o fst) conjs;
*}
text {* 
 f_4 a (C_2 b c) = f_4 a b 
 f_4 a (f_4 b c) = f_4 a b 
 f_4 a (f_4 b c) = f_4 a c 
 f_4 a (C_1 b c) = f_4 a (C_1 b b) 
 f_4 a (C_1 b c) = f_4 a (C_1 c b) 
 f_4 a (C_1 b c) = f_4 a (C_1 c c) 
 --- 
 f_4 a b = f_4 a a 
 f_4 (f_4 a b) c = f_4 (f_4 a a) a 
 f_4 (f_4 a b) c = f_4 (f_4 a a) b 
 f_4 (f_4 a b) c = f_4 (f_4 a a) c 
 f_4 (f_4 a b) c = f_4 (f_4 a b) a 
 f_4 (f_4 a b) c = f_4 (f_4 a b) b 
 f_4 (f_4 a b) c = f_4 (f_4 a c) a 
 f_4 (f_4 a b) c = f_4 (f_4 a c) b 
 f_4 (f_4 a b) c = f_4 (f_4 a c) c 
*}
.
ML {*
  val ((thy_constraints',thy'),(conjs,thms)) = 
      timeit (synth_level1_theorems_for_fun (Fn.mk "f_5")) @{theory};
*}
-- "Print synthesised conjectures"
ML{*
 val _ = map (Trm.print @{context} o fst) thms;
  Pretty.writeln (Pretty.str "---");
  val _ = map (Trm.print @{context} o fst) conjs;
*}
text {* 
 f_5 a (C_2 b c) = f_5 a (C_2 a c) 
 f_5 a (f_5 b c) = f_5 a (f_5 a c) 
 --- 
 f_5 a b = f_5 a a 
 f_5 a (C_2 b c) = f_5 a b 
 f_5 a (f_5 b c) = f_5 a b 
 f_5 a (f_5 b c) = f_5 a c 
 f_5 a (C_1 b c) = f_5 a (C_1 b b) 
 f_5 a (C_1 b c) = f_5 a (C_1 c b) 
 f_5 a (C_1 b c) = f_5 a (C_1 c c) 
 f_5 a (C_1 b c) = f_5 a (C_2 a b) 
 f_5 a (C_1 b c) = f_5 a (C_2 a c) 
 f_5 a (C_1 b c) = f_5 a (f_5 a a) 
 f_5 a (C_2 b c) = f_5 a (C_1 c c) 
 f_5 a (C_2 b c) = f_5 a (f_5 a a) 
 f_5 a (C_2 b c) = f_5 a (f_5 a b) 
 f_5 a (C_2 b c) = f_5 a (f_5 b a) 
 f_5 a (C_2 b c) = f_5 a (f_5 b b) 
 f_5 a (f_5 b c) = f_5 a (f_5 a a) 
 f_5 a (f_5 b c) = f_5 a (f_5 a b) 
 f_5 a (f_5 b c) = f_5 a (f_5 b a) 
 f_5 a (f_5 b c) = f_5 a (f_5 b b) 
 f_5 a (f_5 b c) = f_5 a (f_5 c a) 
 f_5 a (f_5 b c) = f_5 a (f_5 c b) 
 f_5 a (f_5 b c) = f_5 a (f_5 c c) 
 f_5 (f_5 a b) c = f_5 (f_5 a a) a 
 f_5 (f_5 a b) c = f_5 (f_5 a a) b 
 f_5 (f_5 a b) c = f_5 (f_5 a a) c 
 f_5 (f_5 a b) c = f_5 (f_5 a b) a 
 f_5 (f_5 a b) c = f_5 (f_5 a b) b 
 f_5 (f_5 a b) c = f_5 (f_5 a c) a 
 f_5 (f_5 a b) c = f_5 (f_5 a c) b 
 f_5 (f_5 a b) c = f_5 (f_5 a c) c 
 f_5 a (C_2 (C_2 b c) c) = f_5 a b 
 f_5 a (C_2 (f_5 b a) c) = f_5 a b 
 f_5 a (C_2 (f_5 b b) c) = f_5 a b 
 f_5 a (C_2 (f_5 a b) c) = f_5 a b 
 f_5 a (f_5 b (f_5 c a)) = f_5 a c 
 f_5 a (f_5 b (f_5 c b)) = f_5 a c 
 f_5 a (f_5 b (f_5 c c)) = f_5 a c 
 f_5 a (f_5 b (f_5 a c)) = f_5 a c 
 f_5 a (f_5 b (f_5 b c)) = f_5 a c 
 f_5 a (f_5 a (C_2 b c)) = f_5 a b 
 f_5 a (f_5 a (f_5 b c)) = f_5 a b 
 f_5 a (f_5 a (f_5 b c)) = f_5 a c 
 f_5 a (f_5 (f_5 b c) a) = f_5 a b 
 f_5 a (f_5 (f_5 b c) a) = f_5 a c 
 f_5 a (f_5 (f_5 b c) b) = f_5 a c 
 f_5 a (f_5 (f_5 b c) c) = f_5 a b 
 f_5 a (f_5 (f_5 b a) c) = f_5 a b 
 f_5 a (f_5 (f_5 b b) c) = f_5 a b 
 f_5 a (f_5 (f_5 a b) c) = f_5 a b 
*}
.
ML {*
  val ((thy_constraints',thy'),(conjs,thms)) = 
      timeit (synth_level1_theorems_for_fun (Fn.mk "f_6")) @{theory};
*}
-- "Print synthesised conjectures"
ML{*
 val _ = map (Trm.print @{context} o fst) thms;
  Pretty.writeln (Pretty.str "---");
  val _ = map (Trm.print @{context} o fst) conjs;
*}
text {* 
 f_6 (f_6 a b) c = f_6 a b 
 --- 
 f_6 a b = f_6 a a 
 f_6 a (C_2 b c) = f_6 a b 
 f_6 a (f_6 b c) = f_6 a b 
 f_6 a (f_6 b c) = f_6 a c 
 f_6 (f_6 a b) c = f_6 a a 
 f_6 (f_6 a b) c = f_6 a c 
 f_6 a (C_1 b c) = f_6 a (C_1 b b) 
 f_6 a (C_1 b c) = f_6 a (C_1 c b) 
 f_6 a (C_1 b c) = f_6 a (C_1 c c) 
 f_6 a (C_1 b c) = f_6 a (C_2 a b) 
 f_6 a (C_1 b c) = f_6 a (C_2 a c) 
 f_6 a (C_1 b c) = f_6 a (f_6 a a) 
 f_6 a (C_2 b c) = f_6 a (C_1 c c) 
 f_6 a (C_2 b c) = f_6 a (C_2 a c) 
 f_6 a (C_2 b c) = f_6 a (f_6 a a) 
 f_6 a (C_2 b c) = f_6 a (f_6 a b) 
 f_6 a (C_2 b c) = f_6 a (f_6 b a) 
 f_6 a (C_2 b c) = f_6 a (f_6 b b) 
 f_6 a (f_6 b c) = f_6 a (f_6 a a) 
 f_6 a (f_6 b c) = f_6 a (f_6 a b) 
 f_6 a (f_6 b c) = f_6 a (f_6 a c) 
 f_6 a (f_6 b c) = f_6 a (f_6 b a) 
 f_6 a (f_6 b c) = f_6 a (f_6 b b) 
 f_6 a (f_6 b c) = f_6 a (f_6 c a) 
 f_6 a (f_6 b c) = f_6 a (f_6 c b) 
 f_6 a (f_6 b c) = f_6 a (f_6 c c) 
 f_6 a (C_2 (C_2 b c) c) = f_6 a b 
 f_6 a (C_2 (f_6 b a) c) = f_6 a b 
 f_6 a (C_2 (f_6 b b) c) = f_6 a b 
 f_6 a (C_2 (f_6 a b) c) = f_6 a b 
 f_6 a (f_6 b (f_6 c a)) = f_6 a c 
 f_6 a (f_6 b (f_6 c b)) = f_6 a c 
 f_6 a (f_6 b (f_6 c c)) = f_6 a c 
 f_6 a (f_6 b (f_6 a c)) = f_6 a c 
 f_6 a (f_6 b (f_6 b c)) = f_6 a c 
 f_6 a (f_6 a (C_2 b c)) = f_6 a b 
 f_6 a (f_6 a (f_6 b c)) = f_6 a b 
 f_6 a (f_6 a (f_6 b c)) = f_6 a c 
*}

ML {*
  val ((thy_constraints',thy'),(conjs,thms)) = 
      timeit (synth_level1_theorems_for_fun (Fn.mk "f_7")) @{theory};
*}
-- "Print synthesised conjectures"
ML{*
 val _ = map (Trm.print @{context} o fst) thms;
  Pretty.writeln (Pretty.str "---");
  val _ = map (Trm.print @{context} o fst) conjs;
*}
text {* 
 f_7 a (C_1 b c) = f_7 a (C_1 b b) 
 f_7 a (C_1 b c) = f_7 a (C_1 c b) 
 f_7 a (C_1 b c) = f_7 a (C_1 c c) 
 f_7 a (f_7 b c) = f_7 a (f_7 a c) 
 f_7 a (f_7 b c) = f_7 a (f_7 b b) 
 --- 
 f_7 a b = f_7 a a 
 f_7 a (C_2 b c) = f_7 a b 
 f_7 a (f_7 b c) = f_7 a b 
 f_7 a (f_7 b c) = f_7 a c 
 f_7 a (C_1 b c) = f_7 a (C_2 a b) 
 f_7 a (C_1 b c) = f_7 a (C_2 a c) 
 f_7 a (C_1 b c) = f_7 a (f_7 a a) 
 f_7 a (C_2 b c) = f_7 a (C_1 c c) 
 f_7 a (C_2 b c) = f_7 a (C_2 a c) 
 f_7 a (C_2 b c) = f_7 a (f_7 a a) 
 f_7 a (C_2 b c) = f_7 a (f_7 a b) 
 f_7 a (C_2 b c) = f_7 a (f_7 b a) 
 f_7 a (C_2 b c) = f_7 a (f_7 b b) 
 f_7 a (f_7 b c) = f_7 a (f_7 a a) 
 f_7 a (f_7 b c) = f_7 a (f_7 a b) 
 f_7 a (f_7 b c) = f_7 a (f_7 b a) 
 f_7 a (f_7 b c) = f_7 a (f_7 c a) 
 f_7 a (f_7 b c) = f_7 a (f_7 c b) 
 f_7 a (f_7 b c) = f_7 a (f_7 c c) 
 f_7 (f_7 a b) c = f_7 (f_7 a a) a 
 f_7 (f_7 a b) c = f_7 (f_7 a a) b 
 f_7 (f_7 a b) c = f_7 (f_7 a a) c 
 f_7 (f_7 a b) c = f_7 (f_7 a b) a 
 f_7 (f_7 a b) c = f_7 (f_7 a b) b 
 f_7 (f_7 a b) c = f_7 (f_7 a c) a 
 f_7 (f_7 a b) c = f_7 (f_7 a c) b 
 f_7 (f_7 a b) c = f_7 (f_7 a c) c 
 f_7 a (C_2 (C_2 b c) c) = f_7 a b 
 f_7 a (C_2 (f_7 b a) c) = f_7 a b 
 f_7 a (C_2 (f_7 b b) c) = f_7 a b 
 f_7 a (C_2 (f_7 a b) c) = f_7 a b 
 f_7 a (f_7 b (f_7 c a)) = f_7 a c 
 f_7 a (f_7 b (f_7 c b)) = f_7 a c 
 f_7 a (f_7 b (f_7 c c)) = f_7 a c 
 f_7 a (f_7 b (f_7 a c)) = f_7 a c 
 f_7 a (f_7 b (f_7 b c)) = f_7 a c 
 f_7 a (f_7 a (C_2 b c)) = f_7 a b 
 f_7 a (f_7 a (f_7 b c)) = f_7 a b 
 f_7 a (f_7 a (f_7 b c)) = f_7 a c 
 f_7 a (f_7 (f_7 b c) a) = f_7 a b 
 f_7 a (f_7 (f_7 b c) a) = f_7 a c 
 f_7 a (f_7 (f_7 b c) b) = f_7 a c 
 f_7 a (f_7 (f_7 b c) c) = f_7 a b 
 f_7 a (f_7 (f_7 b a) c) = f_7 a b 
 f_7 a (f_7 (f_7 b b) c) = f_7 a b 
 f_7 a (f_7 (f_7 a b) c) = f_7 a b 
*}

ML {*
  val ((thy_constraints',thy'),(conjs,thms)) = 
      timeit (synth_level1_theorems_for_fun (Fn.mk "f_8")) @{theory};
*}
-- "Print synthesised conjectures"
ML{*
 val _ = map (Trm.print @{context} o fst) thms;
  Pretty.writeln (Pretty.str "---");
  val _ = map (Trm.print @{context} o fst) conjs;
*}
text {* 
 f_8 a b = f_8 a a 
 f_8 a (C_2 (f_8 b b) c) = f_8 a b 
 f_8 a (C_2 (f_8 a b) c) = f_8 a b 
 --- 
 f_8 a (C_2 b c) = f_8 a b 
 f_8 a (C_1 b c) = f_8 a (C_1 b b) 
 f_8 a (C_1 b c) = f_8 a (C_1 c b) 
 f_8 a (C_1 b c) = f_8 a (C_1 c c) 
 f_8 a (C_1 b c) = f_8 a (C_2 a b) 
 f_8 a (C_1 b c) = f_8 a (C_2 a c) 
 f_8 a (C_2 b c) = f_8 a (C_1 c c) 
 f_8 a (C_2 b c) = f_8 a (C_2 a c) 
 f_8 (f_8 a b) c = f_8 (f_8 a a) a 
 f_8 (f_8 a b) c = f_8 (f_8 a a) b 
 f_8 (f_8 a b) c = f_8 (f_8 a a) c 
 f_8 (f_8 a b) c = f_8 (f_8 a b) a 
 f_8 (f_8 a b) c = f_8 (f_8 a b) b 
 f_8 (f_8 a b) c = f_8 (f_8 a c) a 
 f_8 (f_8 a b) c = f_8 (f_8 a c) b 
 f_8 (f_8 a b) c = f_8 (f_8 a c) c 
 f_8 a (C_2 (C_2 b c) c) = f_8 a b 
 f_8 a (C_2 (f_8 b a) c) = f_8 a b 
*}



ML {*
  val ((thy_constraints',thy'),(conjs,thms)) = 
      timeit (synth_level1_theorems_for_fun (Fn.mk "f_10")) @{theory};
*}
-- "Print synthesised conjectures"
ML{*
 val _ = map (Trm.print @{context} o fst) thms;
  Pretty.writeln (Pretty.str "---");
  val _ = map (Trm.print @{context} o fst) conjs;
*}


ML {*
  val ((thy_constraints',thy'),(conjs,thms)) = 
      timeit (synth_level1_theorems_for_fun (Fn.mk "f_11")) @{theory};
*}
-- "Print synthesised conjectures"
ML{*
 val _ = map (Trm.print @{context} o fst) thms;
  Pretty.writeln (Pretty.str "---");
  val _ = map (Trm.print @{context} o fst) conjs;
*}


ML {*
  val ((thy_constraints',thy'),(conjs,thms)) = 
      timeit (synth_level1_theorems_for_fun (Fn.mk "f_12")) @{theory};
*}
-- "Print synthesised conjectures"
ML{*
 val _ = map (Trm.print @{context} o fst) thms;
  Pretty.writeln (Pretty.str "---");
  val _ = map (Trm.print @{context} o fst) conjs;
*}

