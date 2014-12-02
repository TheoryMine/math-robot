(* meta-theory *)
structure MThy
= struct

(* constructor names *)
structure Cn :> SSTR_NAMES = 
  struct open SStrName; val default_name = mk "Ca"; end;

(* type names: elements/arguments in a constructor *)
structure Tn :> SSTR_NAMES = 
  struct open SStrName; val default_name = mk "Ta"; end;

(* names for variables *)
structure Vr :> SSTR_NAMES = 
  struct open SStrName; val default_name = mk "x_a"; end;

(* names for function symbols *)
structure Fn :> SSTR_NAMES = SStrName;

structure CnTnMap = NameMapFun(structure Dom = Cn and Cod = Tn);

structure CnFnMap = NameMapFun(structure Dom = Cn and Cod = Fn);



(* elements kinds in a datatype - either recursive, of the name of a type *)
datatype elem_typ = 
         Rec | Typ of Tn.name;

(* order for element types *)
fun elem_typ_ord (Rec,Rec) = EQUAL
  | elem_typ_ord (Rec, Typ _) = LESS
  | elem_typ_ord (Typ _, Rec) = GREATER
  | elem_typ_ord (Typ t1, Typ t2) = Tn.name_ord(t1,t2);

(* smallest elem_typ *)
val bot_elem = Rec;
fun top_elem nset = Tn.NSet.get_first nset;

fun maybef f NONE = NONE
  | maybef f (SOME x) = SOME (f x);

(* make lazy evaluated sequence of elements from a suc option function. *)
fun mk_suc_seq f init = 
    let (* seq aux maker *)
      fun mk_suc_seq' x () = 
        (f x) |> maybef (fn x' => (x',Seq.make (mk_suc_seq' x')));
    in Seq.make (mk_suc_seq' init) end;

(* Suc operation for elem_typ, with respect to some given set *)
(* Note: return optional name *)
fun elem_typ_suc' nset Rec = 
    maybef Typ (Tn.NSet.get_first nset)
  | elem_typ_suc' nset (Typ dn) = 
    maybef Typ (Tn.NSet.next_bigger nset dn);

(* smallest list first, then lex on element order  *)
val elem_list_ord = Library.list_ord elem_typ_ord;

(* generic list suc *)
fun list_suc' sucf ordf botf [] = NONE
  | list_suc' sucf ordf botf [h] = maybef single (sucf h)
  | list_suc' sucf ordf botf (h1::h2::l) = 
    (case sucf h1 of 
       NONE => 
       (case list_suc' sucf ordf botf (h2::l) of NONE => NONE
           | SOME h2l' => SOME ((botf h1)::h2l'))
     | SOME h1' => 
       (case ordf (h1',h2) of 
          GREATER => 
          (case list_suc' sucf ordf botf (h2::l) of NONE => NONE
           | SOME h2l' => SOME ((botf h1)::h2l'))
        | _ => SOME (h1'::h2::l)));


(* increment an element list (not changing the number of elements). 
   preserves order, tries to increase the smallest element, if it fails,
   increases the next element and sets first one to bot. *)
fun elem_list_suc' nset l = 
    list_suc' (elem_typ_suc' nset) elem_typ_ord (fn x => bot_elem) l;

(* make length bottom element list of length n - note: it's not all bottom as that would be a datatype that's recursive in all positions. *)
fun mk_bot_nonrec_elem_list nset n = 
    (elem_list_suc' nset (replicate n bot_elem));

fun mk_bot_elem_list nset n = (replicate n bot_elem);

(* datatypes (should be sorted by elem_type) *)
datatype dtyp = DType of elem_typ list (* elements in constructor *) 
                                    list; (* constructors *)


(* there is some recursive element in a list of elements *)
fun is_rec_elem_list l = 
    is_some (find_first (fn Rec => true | Typ _ => false) l);

(* there is some non-recursive case *)
fun is_well_founded (DType ll) = 
    is_some (find_first (not o is_rec_elem_list) ll);

(* there is some recursive case *)
fun is_recursive (DType ll) = 
    is_some (find_first is_rec_elem_list ll);

(* ordering for datatypes: num of constructors first, then lex on element 
   list order (element length, then lex on elements ) *)
fun dtype_ord (DType ll1) (DType ll2) = 
    Library.list_ord elem_list_ord (ll1,ll2);

(* mk next datatype, not changing number of constructors or elements. *)
fun dtyp_suc' nset (DType []) = NONE
  | dtyp_suc' nset (DType ll) = 
    maybef DType
    (list_suc' (elem_list_suc' nset) elem_list_ord 
       (fn l => mk_bot_elem_list nset (length l)) ll);

(* make bottom datatype of given number of construct element lengths: assumes element lengths are in increasing order for well-formedness *)
fun mk_bot_dtyp nset (dtyp_param : int list) = 
    DType (map (mk_bot_elem_list nset) dtyp_param);


(*// interesting program tansform: change to two functions? *)
(* CHECK: isn't this in library *)
fun list_is_sorted ordf [] = true
  | list_is_sorted ordf [h] = true
  | list_is_sorted ordf (h::(l as h2::t)) = 
    (case ordf(h,h2) of GREATER => false 
     | _ => list_is_sorted ordf l);

(* check if all lists are sorted correctly *)
fun dtyp_is_order_correct (DType ll) = 
    (* element lists are sorted *)
    (fold 
      (fn l => fn b => (* all prev lists are sorted and so is this one *)
          b andalso (list_is_sorted elem_typ_ord l))
      ll true)
    (* and constructor list is sorted *)
    andalso (list_is_sorted elem_list_ord ll); 

(* debug check for datatypes being well-formed *)
exception bad_dtyp_exp of dtyp;
fun assert_dtyp_is_order_correct d = 
    if dtyp_is_order_correct d then true 
    else raise bad_dtyp_exp d;


(* increase number of elements upto max, but don't change num of constr *)
fun suc_dtyp_by_elems' maxelems l = 
    list_suc' 
      (fn i => if i < maxelems then SOME (i + 1) else NONE)
      int_ord
      (K 0) l;


(* try to increase elements, if at max, increase constr and start at bot number of elements *)
fun suc_dtyp_param' {maxelems, maxconstrs} l = 
    (case (suc_dtyp_by_elems' maxelems l) of NONE => 
       let val len = length l in 
       if len < maxconstrs then SOME (replicate (len + 1) 0)
       else NONE end
    | SOME l' => SOME l');

(* create sequence of all datatypes *)
fun all_dtyps_upto nset config =
    (mk_suc_seq (suc_dtyp_param' config) [0])
      |> Seq.map (mk_bot_dtyp nset)
      |> Seq.maps (mk_suc_seq (dtyp_suc' nset));


(* create sequence of all datatypes *)
fun all_well_founded_rec_dtyps_upto nset config =
    (mk_suc_seq (suc_dtyp_param' config) [0])
      |> Seq.map (mk_bot_dtyp nset)
      |> Seq.maps (mk_suc_seq (dtyp_suc' nset))
      |> Seq.filter (fn d => is_well_founded d andalso is_recursive d) 


(* datatype construction parameters *)
datatype thy_param = 
         ThyParams of
           { nset : Tn.NSet.T,
             nconstr : int,
             nelems : int,
             ndeps : int };

datatype gen_status =
  GenStatus of 
    {
      can_use_dtyps : dtyp Tn.NTab.T,
      must_use_dtyps : dtyp Tn.NTab.T,
      new_dtyps : dtyp Tn.NTab.T,
      min_nconstr : int,
      min_nelems : int,
      max_nconstr : int,
      max_nelems : int,
      cur_dyp_param : int list,
      level : int,
      last_dtyp : dtyp
     };

fun pretty_dtyp_param l = 
    Pretty.list "dtyp_params[" "]" 
      (map (Pretty.str o Int.toString) l);

val print_dtyp_param = Pretty.writeln o pretty_dtyp_param;


(* Pretty printing *)
fun pretty_elem_typ Rec = 
    Pretty.str "*Rec*"
  | pretty_elem_typ (Typ dn) = Tn.pretty_name dn;

fun pretty_elem_list l = 
    Pretty.list "[" "]" (map pretty_elem_typ l);

val print_elem_list = Pretty.writeln o pretty_elem_list;

fun pretty_dtyp (DType ll) = 
  Pretty.block 
    [Pretty.str "DType: ", 
     Pretty.list "{" "}" 
      (map pretty_elem_list ll)]; 

val print_dtyp = Pretty.writeln o pretty_dtyp;

fun print_all pf sucf x = 
      (pf x; 
       case sucf x of NONE => ()
          | SOME x' => print_all pf sucf x');


(* code for datatypes: unique string names that tell you exactly what 
   the datatype is, independently of how it is named; approx debruijn 
   notation *)
fun pretty_elem_typ_code Rec = Pretty.str "*"
  | pretty_elem_typ_code (Typ n) = Tn.pretty_name n;
fun pretty_elem_list_code l =
    Pretty.block
      [Pretty.str "[", 
       Pretty.block (Library.separate (Pretty.str ",") 
                      (map pretty_elem_typ_code l)),
       Pretty.str "]"];
fun pretty_dtyp_code (DType ll) = 
    Pretty.block
         [Pretty.str "{", 
          Pretty.block (Library.separate (Pretty.str ",") 
                          (map pretty_elem_list_code ll)),
          Pretty.str "}"];

val print_dtyp_code = Pretty.writeln o pretty_dtyp_code;

end; (* struct *)


(* testing code *)
(* 
local open MThy in 
  val nset = Tn.NSet.of_list [Tn.mk "n", Tn.mk "b"];
  val el0 = mk_bot_elem_list nset 2;

  val _ = print_all print_elem_list (elem_list_suc' nset) el0; 

  val dt0 = mk_bot_dtyp nset [1,2,3];
  val _ = print_all print_dtyp_code (dtyp_suc' nset) dt0; 

  val dt0 = mk_bot_dtyp nset [2,2];
  val _ = print_all print_dtyp_code (dtyp_suc' nset) dt0; 

  val _ = print_all print_dtyp_param 
          (suc_dtyp_param' {maxelems=3,maxconstrs=3}) [0]; 

  val sq1 = all_dtyps_upto nset {maxelems=3,maxconstrs=3};
  val sq2 = all_well_founded_rec_dtyps_upto nset {maxelems=3,maxconstrs=3};
  
  val _ = PolyML.print (length (Seq.list_of (Seq.map print_dtyp_code sq2)));
  val _ = PolyML.print (length (Seq.list_of sq1));

end;
*)
(* 

datatypes upto size (3,3): 1561
well-founded rec datatypes upto size (3,3): 1090

datatypes upto size (4,4): 61694
well-founded rec datatypes upto size (4,4): 52634

? how many of these are just instances of known polymorphic types, e.g. 
trees (upto size 3) and lists?

*)


