(* Code to generate datatypes/constructors etc without duplicates in a lazy fashion *)
signature DATA_GEN = sig

  datatype elem_typ = Rec | Typ of Tn.name;
  datatype dtyp = DType of elem_typ list (* elements in constructor *) 
                                    list; (* constructors *)

  (* element operations *)
  val elem_typ_suc' : Tn.NSet.T -> elem_typ -> elem_typ option 
  val elem_typ_ord : elem_typ * elem_typ -> order

  (* element list operations *)
  val elem_list_suc' : Tn.NSet.T -> elem_typ list -> elem_typ list option
  val elem_list_ord : elem_typ list * elem_typ list -> order 
  (* bottom element list of a given size *)
  (* bottom creation function; for basic types 'a is ignored; because the bottom element is the
     recursive call; and thus independent of the set of types we are working in. For non-recursive
     functions, it is the bottom element of the set of types. *)
  val mk_bot_elem_list : 'a -> int (* list size *) -> elem_typ list 
  val mk_bot_wf_elem_list : Tn.NSet.T -> int (* list size *) -> elem_typ list option

  (* non-recursive element list construction *)
  val nr_elem_list_suc' : Tn.NSet.T -> elem_typ list -> elem_typ list option
  val nr_mk_bot_elem_list : Tn.NSet.T -> int (* list size *) -> elem_typ list option

  (* some recursive checking functions for elements and datatypes *)
  val is_rec_elem_list : elem_typ list -> bool
  val is_recursive : dtyp -> bool 
  (* correctness of datatypes *)
  val is_well_founded : dtyp -> bool
  val dtyp_is_order_correct : dtyp -> bool

  (* create the next datatype *)
  val dtyp_suc' : Tn.NSet.T -> dtyp -> dtyp option 
  val dtype_ord : dtyp -> dtyp -> order
  val mk_bot_dtyp : 'a (* type name set, unused *) 
                    -> int list (* size of each list of elements *)
                    -> dtyp (* bottom datatype *)

  (* datatype error handling *)
  exception bad_dtyp_exp of dtyp; (* errors for badly formed dtyps *)
  val assert_dtyp_is_order_correct : dtyp -> bool

  (* datatype construction parameterisation *)
  val suc_dtyp_param' : {maxelems: int, maxconstrs: int} -> int list -> int list option
  val suc_dtyp_by_elems' : int -> int list -> int list option 

  (* construction of all datatypes upto param limits *)
  val all_dtyps_upto : Tn.NSet.T -> {maxelems: int, maxconstrs: int} -> dtyp Seq.seq
  val all_well_founded_rec_dtyps_upto 
      : Tn.NSet.T -> {maxelems: int, maxconstrs: int} -> dtyp Seq.seq

  (* generic tools for lazy enumeration/construction of datatypes based on lists, 
     and suc operations *)
  val list_is_sorted : ('a * 'a -> order) -> 'a list -> bool 
  val mk_suc_seq : ('a -> 'a option) -> 'a -> 'a Seq.seq (* starts at "Suc(a)" *)
  val suc_seq : ('a -> 'a option) -> 'a -> 'a Seq.seq (* starts at "a" *)

  (* list_suc' = sucessor for lists representing multi-sets of things *)
  val list_suc' : ('a -> 'a option) (* suc operation *)
               -> ('a * 'a -> order) (* order relation *)
               -> ('a -> 'a) (* mk_bottom value function. e.g. 'a list => zero list of same size *)
               -> 'a list (* list construction *)
               -> 'a list option (* oprional next element *)
  (* list_suc2' = successor for lists representing differences upto some value ('s) *)
  val list_suc2' : ('s -> 'a -> ('s * 'a) option) (* suc operation *)
               -> ('s -> 'a -> ('s * 'a)) (* bottom value. e.g. 'a list => list of 1's *)
               -> ('s * ('a list)) (* sum and list construction *)
               -> ('s * ('a list)) option (* oprional next element *)

  (* constructs list of ways to choose n things from a list of m, where order of chosen 
     elements doesn't matter. The result is a list of distances to walk to pick next element 
     in the list. First number must leq to second; resulting list has size n. sum of distances always less than m. *)
  exception n_too_small_exp of int * int;
  exception list_too_small_exp of string;
  val seq_of_choose_n_distinct_from_m : int -> int -> int list Seq.seq; (* offset poistions *)
  val seq_of_choose_n_from_list : int -> 'a list -> 'a list Seq.seq; (* sublists of size n *)
  val choose_by_distances_in_list : 'a list -> int list -> 'a list; (* sublist from distances *)

  (* pretty printing *)
  val print_elem_list : elem_typ list -> unit
  val print_dtyp_param : int list -> unit 
  val print_dtyp_code : dtyp -> unit 
  val print_dtyp : dtyp -> unit
  val print_all : ('a -> 'b) -> ('a -> 'a option) -> 'a -> unit 
  val pretty_elem_typ_code : elem_typ -> Pretty.T
  val pretty_elem_typ : elem_typ -> Pretty.T 
  val pretty_elem_list_code : elem_typ list -> Pretty.T
  val pretty_elem_list : elem_typ list -> Pretty.T 
  val pretty_dtyp_param : int list -> Pretty.T
  val pretty_dtyp_code : dtyp -> Pretty.T 
  val pretty_dtyp : dtyp -> Pretty.T (* DType { ... } *)
  val pretty_dtyp' : dtyp -> Pretty.T (* doesn't print DType at the front *)
  (* for serialisation as ML code *)
  val ml_pretty_elem_list : elem_typ list -> Pretty.T 
  val ml_pretty_elem_typ : elem_typ -> Pretty.T
  val ml_pretty_dtyp : dtyp -> Pretty.T (* DType { ... } *)
end;

(* structure *)
structure DataGen : DATA_GEN
= struct 
(* local open TM_Types in *)

  (** Generic lazy iteration by Suc and list constructions **)
  (* generic suc for a sorted list representing a multi-set of values. 
     NONE is overflow. 
     Invariant: list is sorted: given a list l, for any pairwise elements h1 and h2, i.e.: 
     if "l = start @ [h1, h2] @ end" then "ord(h1,h2) =/= GREATER"

     The botf creates the minimal element of the argument it was given. 
     e.g. if given digits botf(9) = 0. Reason for it not being a constant is that it can be more 
     general and work on lists, and the bottom value may then depend on the lists size.
     
     The ordf compares two elements. This is used to allows 
     Suc to preserve sortedness. e.g. Suc {7,7,0} = {}
  *)
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

  (* construct all lists of numbers, such that there sum is less than some value (s). *)
  fun list_suc2' sucf botf (s,[]) = NONE
    | list_suc2' sucf botf (s,[h]) = 
      (case (sucf s h) of SOME (s',h') => SOME (s',[h']) | NONE => NONE)
    | list_suc2' sucf botf (s,h1::l2) = 
      (case sucf s h1 of 
         NONE => let val (s',h1') = (botf s h1) in 
                 (case list_suc2' sucf botf (s',l2) 
                    of NONE => NONE
                     | SOME (s'',h2l') => SOME (s'',h1'::h2l')) end
       | SOME (s',h1') => SOME (s', h1'::l2));
  
  (* make lazy evaluated sequence of elements from a suc option function. *)
  fun mk_suc_seq f init = 
      let (* seq aux maker *)
        fun mk_suc_seq' x () = 
          (f x) |> maybef (fn x' => (x',Seq.make (mk_suc_seq' x')));
      in Seq.make (mk_suc_seq' init) end;
  fun suc_seq f init = Seq.cons init (mk_suc_seq f init);

  (* costructs a list of differences to select n elements from a list of m, 
     with no duplicate choices  *)
  exception n_too_small_exp of int * int;
  (* IMPROVE: use a lazy tree structure to share the common prefix part... ? *)
  fun seq_of_choose_n_distinct_from_m' n m = 
      suc_seq (list_suc2' 
                    (fn s => fn i => if s < m then SOME (s +1, i + 1) else NONE) (* l is max *)
                    (fn s => fn b => (s + 1 - b,1)) (* making b bottom value (1) *)
                    ) (n, replicate n 1)
        |> Seq.map snd;
       (*   |> Seq.map (fn (_,h::l) => (h - 1) ::l); *)
  fun seq_of_choose_n_distinct_from_m n m = 
      if m < n then raise n_too_small_exp (n,m)
      else seq_of_choose_n_distinct_from_m' n m;

  exception list_too_small_exp of string;
  fun choose_by_distances_in_list l [] = []
    | choose_by_distances_in_list [] (dh::dl) = 
      raise list_too_small_exp "choose_by_distances_in_list"
    | choose_by_distances_in_list (l2 as h::t) (dh::dl) = 
      if dh < 2 then h:: (choose_by_distances_in_list t dl)
      else choose_by_distances_in_list t ((dh - 1)::dl);

  fun seq_of_choose_n_from_list n l = 
      Seq.map (choose_by_distances_in_list l)
              (seq_of_choose_n_distinct_from_m n (length l));


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
  fun bot_elem_of_nset nset = Typ (the (Tn.NSet.get_first nset));
  fun top_elem nset = the (Tn.NSet.get_first nset);
  
  (* Suc operation for elem_typ, with respect to some given set *)
  (* Note: return optional name *)
  fun elem_typ_suc' nset Rec = maybef Typ (Tn.NSet.get_first nset)
    | elem_typ_suc' nset (Typ dn) = maybef Typ (Tn.NSet.next_bigger nset dn);
  
  (* smallest list first, then lex on element order  *)
  val elem_list_ord = Library.list_ord elem_typ_ord;
  
  (* increment an element list (not changing the number of elements). 
     preserves order, tries to increase the smallest element, if it fails,
     increases the next element and sets first one to bot. 
     Basically: this is like generalised binary (to nset-ary) notation of numbers
  *)
  fun elem_list_suc' nset l = 
      list_suc' (elem_typ_suc' nset) elem_typ_ord (fn x => bot_elem) l;
  (* make length bottom element list of length n - note: it's not all bottom as that would be a 
     datatype that's recursive in all positions. *)
  fun mk_bot_wf_elem_list nset n = 
      (elem_list_suc' nset (replicate n bot_elem));
  fun mk_bot_elem_list nset n = (replicate n bot_elem);

  (* as above but for non-recursive data; bottom element is that of the type name set (nset) *)
  (* assumes nset is not empty *)
  fun nr_elem_list_suc' nset l = 
      let val bot_elem = bot_elem_of_nset nset;
      in list_suc' (elem_typ_suc' nset) elem_typ_ord (fn x => bot_elem) l end;
  fun nr_mk_bot_elem_list nset n = 
      (nr_elem_list_suc' nset (replicate n (bot_elem_of_nset nset)));

  
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
  
  (* make bottom datatype of given number of construct element lengths: assumes element lengths 
     are in increasing order for well-formedness *)
  fun mk_bot_dtyp nset (dtyp_param : int list) = 
      DType (map (mk_bot_elem_list nset) dtyp_param);
  
  
  (* NOTE: interesting program tansform: change to two functions? *)
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
  
  (* create sequence of all datatypes 
       nset : DN.NSet.T : the set of base type names from which to construct new types
       config : { maxelems : int, maxconstr : int } : limits size of types 
     Returns: lazy list of all datatypes 
  *)
  fun all_well_founded_rec_dtyps_upto nset config =
      (mk_suc_seq (suc_dtyp_param' config) [0])
        |> Seq.map (mk_bot_dtyp nset)
        |> Seq.maps (mk_suc_seq (dtyp_suc' nset))
        |> Seq.filter (fn d => is_well_founded d andalso is_recursive d) 
  
  fun pretty_dtyp_param l = 
      Pretty.list "dtyp_params[" "]" 
        (map (Pretty.str o Int.toString) l);
  
  val print_dtyp_param = Pretty.writeln o pretty_dtyp_param;
  
  (* Pretty printing *)
  fun pretty_elem_typ Rec = 
      Pretty.str "*Rec*"
    | pretty_elem_typ (Typ dn) = Tn.pretty_name dn;
  
  fun pretty_elem_list l = Pretty.list "[" "]" (map pretty_elem_typ l);
  val print_elem_list = Pretty.writeln o pretty_elem_list;
  
  fun pretty_dtyp' (DType ll) = 
    Pretty.block 
      [Pretty.list "{" "}" 
        (map pretty_elem_list ll)]; 

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

  (* for serialisation as ML code *)
  (* IMPROVE: assumes that string_of_name gets parsed to the same name,  
     and that it doesn't contain quote chars. *)
  fun ml_pretty_elem_typ Rec = Pretty.str "DataGen.Rec"
    | ml_pretty_elem_typ (Typ n) = 
      Pretty.block [Pretty.str "DataGen.Typ (Tn.mk ", Pretty.quote (Tn.pretty_name n), Pretty.str ")"];
  fun ml_pretty_elem_list l = Pretty.list "[" "]" (map ml_pretty_elem_typ l);
  fun ml_pretty_dtyp (DType ll) = 
    Pretty.block 
      [Pretty.str "Dtype ",
       Pretty.list "[" "]" 
        (map ml_pretty_elem_list ll)]; 
  
  
  
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

(* end; *) (* local (open TMTypes) *)
end; (* struct *)
