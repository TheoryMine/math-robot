theory "run_synth"
imports "tm_synth"
begin

ML {*
val (goodn,
     ignoredn,
     badfunn,
     funerrorl) =
  run_synth (Tn.mk "T_13")
            (0,  (* skip first this many functions *)
             100,   (* Synth theorems for this many new functions *)
             0, 1) (* Generate all functions (those indexes: 0 mod 1) *)
            1      (* one non-recursive argument for the generated functions *)
            @{theory};
*}

ML {*
tracing ("Good Functions: " ^ (Int.toString goodn));
tracing ("Ignored Functions: " ^ (Int.toString ignoredn));
tracing ("Bad Functions: " ^ (Int.toString badfunn));
tracing ("Fun Synth Errors: " ^ (Int.toString (length funerrorl)));
tracing ("Synthesis completed.");
*}

end
