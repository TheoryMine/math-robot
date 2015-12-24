theory "run_synth"
imports "tm_synth"
begin

ML {*
val (goodn,
     ignoredn,
     badfunn,
     funerrorl,
     prferrorl) =
  run_synth (Tn.mk "T_10")
            (446,  (* skip first this many functions *)
             10,   (* Synth theorems for this many new functions *)
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

end
