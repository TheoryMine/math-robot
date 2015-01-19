theory argument_neglecting
imports IsaP
begin

-- "Light-weight, quick check for functions that neglect arguments"

ML {* 
signature FastArgNeglect =
sig 

  val base_and_step_cases_of_eqns : term list -> term list * term list

  (* the positions that are neglected by every one of these defining equations *)
  

end;

structure FastArgNeglect =
struct

(* Quick syntaxtic check for unused free vars: returns the frees that are not 
   in the term *)
fun syntactically_arg_neglecting_term frees t = 
    let val t_frees = (fold Symtab.update (Trm.frees_of t) Symtab.empty);
    in 
      (* Return the ignored Frees *)
      map_filter (fn (i,(n,ty)) => case (Symtab.lookup t_frees n) of 
                                    NONE => SOME (i,n) | SOME _ => NONE) frees
    end;

fun is_syntactically_arg_neglecting_term frees t = 
    null (syntactically_arg_neglecting_term frees t);

(* t1 := "f a_0, ... a_n" and t2 contains all of a_i where a_i is a Free var *)
fun syntactically_arg_neglecting_termrw (t1,t2) = 
    let val (h,ts) = Term.strip_comb t1
        (* Need to know the position of ignored args, in case different cases
           of def use different names for Frees *)
        val indexed_args = Library.map_index I ts
        val frees = (map_filter (fn (i,Free x) => SOME (i,x) | _ => NONE) indexed_args);
    in syntactically_arg_neglecting_term frees t2 end;

fun dest_eq ((Const("Trueprop", Type("fun", [Type("bool", []), Type("prop", [])]))) $
 (((Const("op =", Type("fun", [_, Type("fun", [_, Type("bool", [])])]))) $ lhs) $ rhs))
 = (lhs,rhs);

val syntactically_arg_neglecting_termeq = syntactically_arg_neglecting_termrw o dest_eq;

(* Checks if the argument in the same index is ignored by all cases *)
fun syntactically_arg_neglecting_fundef def_eqs = 
  let
    fun ignored_in_all_aux [] xs = false
      | ignored_in_all_aux (p::ps) xs = 
          List.exists (fn (i,nm) => 
                   Library.forall (fn ignored => 
                               Library.member (fn ((i1,_),(i2,_)) => i1=i2) ignored (i,nm))
                               xs) 
         (p::ps)
    fun ignored_in_all [] = false
      | ignored_in_all (x::xs) = ignored_in_all_aux x xs
  in
    ignored_in_all (map syntactically_arg_neglecting_termeq def_eqs)
  end;


(* Homogenises naming of variables to avoid keeping track of argument positions *)
fun normalise_arguments eq =
    let
      val eq' = (Term_Subst.zero_var_indexes o Logic.varify_global) eq
      val (_,args) = eq' |> (HOLogic.dest_eq o HOLogic.dest_Trueprop) |> fst |> Term.strip_comb
      fun norm_arg _ eq [] = eq
        | norm_arg i eq (arg :: args) = (case arg 
              of Var (_,typ) => norm_arg (i+1) (Term.subst_free [(arg,Var (("x",i),typ))] eq) args
            | _ => norm_arg (i+1) eq args)
    in norm_arg 1 eq' args end

(* If there is a recursive call on the right hand side of the equation then it is a step case *)
fun is_step_case eq =
    let
      val (el,er) = (HOLogic.dest_eq o HOLogic.dest_Trueprop) eq
      val (elhead,_) = Term.strip_comb el
    in Term.exists_subterm (fn t => (is_equal o Term_Ord.fast_term_ord) (elhead, t)) er end

(* Separates base cases and step cases *)
fun base_and_step_cases_of_eqns eqns = 
    fold (fn a => fn (l,r) => if is_step_case a then (l,a :: r) else (a :: l,r)) eqns ([],[])

(* Detects trivial argument neglecting patterns like:
  base case: f (C0 x) y = K x
  step case: f (C1 x) y = f x (G y)
  i.e. where base case ignores the second argument 
  and step case just puts stuff into the second argument.
*)
fun pattern_arg_neglecting_fundef eqns =
    let
      val eqns = map normalise_arguments eqns
      val (bases,steps) = base_and_step_cases_of_eqns eqns
      val base = hd bases
      val (bl,_) = (HOLogic.dest_eq o HOLogic.dest_Trueprop) base
      val (blhead,blargs) = Term.strip_comb bl
      fun check_neglected var eqn = 
          let
            val (el,er) = (HOLogic.dest_eq o HOLogic.dest_Trueprop) eqn
          in Term.exists_subterm (fn t => (is_equal o Term_Ord.fast_term_ord) (var, t)) el andalso
             not (Term.exists_subterm (fn t => (is_equal o Term_Ord.fast_term_ord) (var, t)) er) end
      fun check_free (i,v) t =
          let
            val (thead,targs) = Term.strip_comb t
          in if (is_equal o Term_Ord.fast_term_ord) (thead, blhead)
             (* Recursive call *)
             then targs |> nth_drop i
                        |> exists (check_free (i,v))
             (* Non-recursive call *)
             else (is_equal o Term_Ord.fast_term_ord) (thead, v) orelse
                  exists (check_free (i,v)) targs
          end
      fun check_eqn vars eq =
          let val (_,sr) = (HOLogic.dest_eq o HOLogic.dest_Trueprop) eq
          in forall (fn (i,v) => check_free (i,v) sr) vars end
    in
      (* Add all variables (excluding those in recursive position) that do not appear 
         in right hand sides in ALL base cases *)
      not (blargs |> map_index (fn (i,t) => (i, Var (("x",(i+1)),fastype_of t)))
                  |> filter (fn (_,v) => forall (fn eqn => check_neglected v eqn) bases)
                  (* Check that all those variables appear at least once on a different 
                     position of srargs *)
                  |> (fn vars => null vars orelse exists (check_eqn vars) steps))
    end;

end; (* struct *)
*}

ML {* 
let 
val t1 = @{term "a + b + (c :: nat)"};
val t2 = @{term "a + b + (c :: nat) + d"};
val [] = FastArgNeglect.syntactically_arg_neglecting_term (Library.map_index I (Trm.frees_of t1)) t2;
val [_] = FastArgNeglect.syntactically_arg_neglecting_term (Library.map_index I (Trm.frees_of t2)) t1;
in writeln "test passed" end;
*}

ML {*
let 
val t1 = @{prop "f a (b :: nat) = Suc (f a b)"};
val [] = FastArgNeglect.syntactically_arg_neglecting_termrw (FastArgNeglect.dest_eq t1);
val t2 = @{prop "f a (b :: nat) = Suc a"};
val [_] = FastArgNeglect.syntactically_arg_neglecting_termrw (FastArgNeglect.dest_eq t2);
in writeln "test passed" end;
*}
ML {*
(* Need to keep track of index of ignored arg *)

let 
val bad_defs = [@{prop "f 0 b c =  b"}, 
                @{prop "f (Suc x) y z = f x y x"}];
val true = FastArgNeglect.syntactically_arg_neglecting_fundef bad_defs
in writeln "test passed" end;
*}

ML {*
(* Need to keep track of index of ignored arg *)
let val good_defs = [@{prop "f 0 b c =  b"}, 
                     @{prop "f (Suc x) y z = f x y z"}];
val false = FastArgNeglect.syntactically_arg_neglecting_fundef good_defs
val x = FastArgNeglect.pattern_arg_neglecting_fundef good_defs
(* FIXME: x should be true! *)
in (writeln "test passed",x) end;
*}

end;
