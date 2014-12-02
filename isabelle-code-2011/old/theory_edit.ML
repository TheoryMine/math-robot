(* 

  Code to interact with Isabelle/Isar to add new data-types and
  functions to an Isabelle theory.

*)

structure TheoryEdit
= struct

datatype elem_type = 
         Rec | Typ of Dn.name;

fun elem_type_ord Rec Rec = EQUAL
  | elem_type_ord Rec (Typ _) = GREATER
  | elem_type_ord (Typ _) Rec = LESS
  | elem_type_ord (Typ t1) (Type t2) = Dn.name_ord(t1,t2);

val elem_list_ord = Library.list_ord elem_type_ord;

(* datatypes: should be sorted by elem_type *)
datatype dtype = DType of elem_type list (* elements in constructor *) 
                                    list; (* constructors *)

fun dtype_ord (DType ll1) (DType ll2) = 
    Library.list_ord elem_list_ord (ll1,ll2);

(* datatype construction parameters *)
datatype constr_params = 
         ConstrParams 
           { nconstr : int,
             nelems : int,
             ndeps : int }


fun pretty_elem_typ Rec = 
    Pretty.str "*Rec*"
  | pretty_elem_typ (Typ (Term.Type (s,[]))) = Pretty.str s
  | pretty_elem_typ _ = raise ERROR "TheoryEdit: only constant types are allowed";

datatype isa_data_type = 
         IsaDataTy of (bstring (* constructor name *)
                       * elem_type list) list



fun make_elem_type typ_name = [Typ(Type(typ_name,[]))]; 
fun make_term_type typ_name = (Type(typ_name,[])); 


(* make list of types from names (add in recursive case too) *)
fun list_typ_choices typset = 
    ((map (make_elem_type o Dn.string_of_name)
          (Dn.NSet.list_of typset))
     @ [[Rec]]);

(*fun create_rec_length_constructors typnames 1 = [[Rec]]
  | create_rec_length_constructors typnames n = 
    cross_prod 
      (list_typ_choices typnames)
      (create_rec_length_constructors typnames (n-1));*)

fun create_rec_length_constructors typnames 1 = [[Rec]]
  | create_rec_length_constructors typnames n = 
    cross_prod_2
      (list_typ_choices typnames)
      (create_rec_length_constructors typnames (n-1))
        (list_typ_choices typnames);
  



fun create_rec_constructors typnames 0 = []
  | create_rec_constructors typnames n = 
    (create_rec_length_constructors typnames n) @ 
    (create_rec_constructors typnames (n-1));

(*fun create_constructors typnames 1 = 
    list_typ_choices typnames
  | create_constructors typnames n = 
    cross_prod
      (* or-choices of new type to add to front of all 
         previous element lists *)
      (list_typ_choices typnames)
      (create_constructors typnames (n-1));*)

fun create_constructors typnames 1 = 
    list_typ_choices typnames
  | create_constructors typnames n = 
    cross_prod_2
      (* or-choices of new type to add to front of all 
         previous element lists *)
      (list_typ_choices typnames)
      (create_constructors typnames (n-1))  
        (list_typ_choices typnames);

fun create_all_constructors typnames 0 = []
  | create_all_constructors typnames n = 
    (create_constructors typnames n) @ 
    (create_all_constructors typnames (n-1));


exception nelems_too_little
exception nconstr_too_little

fun create_data_type typnames {nelems = 0, nconstr} = raise nelems_too_little
  | create_data_type typnames {nelems, nconstr = 0 } = raise nconstr_too_little
  | create_data_type typnames {nelems, nconstr = 1 } = raise nconstr_too_little
  | create_data_type typnames {nelems, nconstr = 2 } =
    let
      (*al base_cost = list_of_list (create_base_constructor m);*)
      val base_cost_2 = [[[]]];
      val rec_cost = 
          list_of_list (create_rec_length_constructors typnames nelems );
      val try = cross_prod base_cost_2 rec_cost;
    in try end
  | create_data_type typnames {nelems, nconstr = 3 } = 
    let 
      (*val base_cost = list_of_list (create_base_constructor m);*)
      val base_cost_2 = [[[]]]; 
      val length_cost = list_of_list (create_constructors typnames nelems );
      val rec_cost = list_of_list(create_rec_constructors typnames nelems);
      val all_costr = list_of_list ( create_all_constructors typnames nelems);
      val rec_costr_length = filter (fn a => length (hd a) = nelems ) rec_cost;
      val rec_costr_not_length = filter (fn a => not (length (hd a) = nelems) )
                                        rec_cost;
      val length_non_rec_cost = filter (fn a => not (my_member Rec (hd a))) 
                                    length_cost ;
      val try1 = cross_prod 
                 (cross_prod base_cost_2 rec_costr_length) all_costr;   
      val try2 = cross_prod 
                        (cross_prod base_cost_2 rec_costr_not_length)
                        length_non_rec_cost ;
    in try1 @ try2 end
  | create_data_type typnames {nelems,nconstr} = 
    let val costr = list_of_list(create_all_constructors typnames nelems );
    in cross_prod (create_data_type typnames {nelems = nelems,
                                              nconstr = (nconstr-1)}) costr end;
    

fun attach_name_to_constr d_as_list = 
    fold (fn elems => fn ctab => Cn.NTab.doadd (Cn.default_name,elems) ctab)
         d_as_list Cn.NTab.empty;

(* nelems = number of and-/element choices in datatype
   nconstr = number of constructors 

   creates all datatypes with exactly 3 constructors, and with one
   constructor with exactly 3 elements, although other constructors
   can have less. -- is this what we want???

   FIXME: don't create isomorphic variants of the same datatype. 
*)
fun mk_isa_datatype nconstr_and_nelems dtab = 
     fold (fn d_as_list => fn dtab =>
             let val ctab = attach_name_to_constr d_as_list
             in Dn.NTab.doadd (Dn.default_name,ctab) dtab end)
         (create_data_type (Dn.NTab.get_nameset dtab) nconstr_and_nelems)
         dtab;


fun add_datatype name (IsaDataTy constrs) thy = thy;
(* 
  let
    val rec_type = Type (Sign.full_name thy name, []);
    fun elem_type Rec = rec_type
      | elem_type (Typ T) = T;
    val (thms, thy') = Datatype.add_datatype {quiet=true,strict=false}
      [name] [([], name, NoSyn, map (fn (c, Ts) => (c, map elem_type Ts, NoSyn)) constrs)] thy
  in (thms,thy') end;
*)

local
(* 
  val by_pat_completeness_simp =
    Proof.global_terminal_proof
      (Method.Basic (K FundefDatatype.pat_completeness, Position.none),
       SOME (Method.Source_i (Args.src (("HOL.auto", []), Position.none))));

  val termination_by_lexicographic_order =
    Fundef.setup_termination_proof NONE
    #> Proof.global_terminal_proof
      (Method.Basic (Lexicographic_Order.lexicographic_order [], Position.none), NONE);
*)
in
  fun add_function name eqs thy = thy;

(*   fun add_function name eqs thy =
    let
      val group = serial_string ();
      val config = FundefCommon.FundefConfig
        {sequential = false, default = "%x. arbitrary", domintros = false, tailrec = false};
    in
      TheoryTarget.init NONE thy
      |> LocalTheory.set_group group
      |> Fundef.add_fundef_i
        [(name, NONE, NoSyn)] (map (fn t => (("", []), t)) eqs) config []
      |> by_pat_completeness_simp
      |> LocalTheory.restore
      |> LocalTheory.set_group group
      |> termination_by_lexicographic_order
      |> ProofContext.theory_of
    end;
*)
end


end; (* struct *)
