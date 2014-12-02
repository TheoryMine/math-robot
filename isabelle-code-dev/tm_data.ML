(* *)
signature TM_DATA_IN_CONTEXT = sig
  type ctxt
  val get_dtyps : ctxt -> NamedDType.T Tn.NTab.T;
  val get_typs : ctxt -> (string * typ) Tn.NTab.T;
  val get_typtntab : ctxt -> Tn.name Symtab.table;
  val get_constrs : ctxt -> (string * typ) Fn.NTab.T;
  val get_constcntab : ctxt -> Fn.name Symtab.table;
  val get_ctmap : ctxt -> FnTnMap.T;

  (* true if this type name is a TheoryMine defined type *)
  val is_tm_rec_tn : ctxt -> Tn.name -> bool
  val ripple_thms_of_term : ctxt -> term -> Thm.thm list

  val pretty : ctxt -> Pretty.T
  val print : ctxt -> unit
end

signature TM_DTYPE = sig
  type T (* data about all known TheoryMine datatypes *)

  val tn_of_typ : T -> Term.typ -> Tn.name

  structure Thy : TM_DATA_IN_CONTEXT where type ctxt = theory
  structure Ctxt : TM_DATA_IN_CONTEXT where type ctxt = Proof.context
end

(* *)

signature TM_FUN_IN_CONTEXT = sig
  type ctxt
  val get_fdeps : ctxt -> FnRel.T
  val get_fntab : ctxt -> ((string * Term.typ) * term list) Fn.NTab.T
  val get_fsymtab : ctxt -> Fn.name Symtab.table
  val get_targ_deps : ctxt -> TnFnRel.T
  val get_trec_deps : ctxt -> TnFnRel.T
  val get_tres_deps : ctxt -> TnFnRel.T

  (* is a theorymine defined function *)
  val is_tm_rec_fn : ctxt -> Fn.name -> bool

  val rectyps_of_fname : ctxt -> Fn.name -> (string * Term.typ) list
  val rectns_of_fname : ctxt -> Fn.name -> Tn.NSet.T
  val defthms_of_fname : ctxt -> Fn.name -> Thm.thm list
  val constinfo_of_fname : ctxt -> Fn.name -> string * Term.typ

  val pretty : ctxt -> Pretty.T
  val print : ctxt -> unit
end;

signature TM_FUN = sig
  type T (* data about all known TheoryMine functions *) 
  val constinfo_of_fname : T -> Fn.name -> string * Term.typ
  val rectns_of_fname : T -> Fn.name -> Tn.NSet.T

  structure Thy : TM_FUN_IN_CONTEXT where type ctxt = theory
  structure Ctxt : TM_FUN_IN_CONTEXT where type ctxt = Proof.context
end


signature TM_DATA =
sig
  (* meta-data for datatypes *)
  structure DType : TM_DTYPE  
  (* meta-data for functions *)
  structure Fun : TM_FUN

  (* add an Isabelle type as a base type *)
  val add_base_type : 
      Tn.name (* use exactly this name (raises exxception otherwise) *)
      * Term.typ (* Isabelle typ *)
      -> theory -> theory

  (* create and add a new datatype to Isabelle and TM meta data *)
  val add_new_datatype : Tn.name (* suggested name *)
      -> DataGen.dtyp (* specification of datatype *) 
      -> theory -> theory 

  (* params for function synthesis *)
  datatype fun_param =
           FunParams of
           {rec_tynm : Tn.name, (* type this function is recursive on *)
            arg_tynms : Tn.name list, (* other arguments used *)
            result_tynm : Tn.name, (* result type *)
            cparams : ConstraintParams.T, (* *)
            size : int}; (* max size of RHS *)

  (* list of synthesised functions (elem in sub-list is a constrcutor equation) *)
  val synth_funs : theory -> fun_param -> ((string * Tn.name * typ) * Term.term list) list 

  (* create and add a new function to Isabelle and TM meta data *)
  val add_new_function : 
           Fn.name (* suggested name *)
        -> Term.term list 
        -> theory -> Fn.name * (* fresh name chosen *)
                     (string option (* SOME m = failed with error m, NONE = added *)
                     * theory)

  (* adds a known Isabelle function to TM meta-data *)
  val add_isabelle_function : (string * typ) * term list -> theory -> theory

  (* helper *)
  (* IMPROVE? fix order of args to standard const-style for funinfo ? *)
  (* information about a defining equation *)
  val info_of_defining_eq : theory -> term 
      -> (string (* name of function defined by term *)
          * string (* the type the function is recursive on *)
          * Term.typ (* type of function symbol *)
         )

  val termpair_of_defining_eq : term -> term * term

end;


(* holds the meta-data for TheoryMine: Datatypes and Function stuff *)
structure TM_Data = struct

(* datatype information *)
structure DType
= struct local open DataGen in

  (* the type of the data that is held in a theory*)
  datatype T = MData of  
  {
    (* only theorymine types, with internal representation *) 
    dtyps : NamedDType.T Tn.NTab.T,

    (* map Tn.name to Isabelle type names and types; holds all types we know about (both 
       theorymine types and types we use from Isabelle) *)
    typs : (string * typ) Tn.NTab.T,
    (* mapping from Isabelle full type name to internal type name (tn.name) *)
    typtntab : Tn.name Symtab.table,

    (* constructor to Isabelle string and type *)
    constrs : (string * typ) Fn.NTab.T,
    (* Isabelle constant symbol to TheoryMine constant symbol *)
    constcntab : Fn.name Symtab.table,

    (* the type in which a constructor occurs; 
       note: cod_nset = set of all used constructors *)
    ctmap : FnTnMap.T 
  }

  (* initial empty data *)
  val empty = MData {dtyps = Tn.NTab.empty, 
                     typs = Tn.NTab.empty, 
                     typtntab = Symtab.empty, 
                     constrs = Fn.NTab.empty, 
                     constcntab = Symtab.empty, 
                     ctmap = FnTnMap.empty };

  (* merging simply takes data from second *)
  fun merge (MData rep, MData rep2) = MData rep2;
  (* Merging two theories; if there is a clash, takes types/names from the second theory. *)
  (*   MData { 
      (* (K true) takes second if there is an overlap *)
      dtyps = Tn.NTab.merge_joint (K true) (#dtyps rep) (#dtyps rep2),
      typs = Tn.NTab.merge_joint (K true) (#typs rep) (#typs rep2),
      typtntab = Symtab.merge (K true) (#typtntab rep, #typtntab rep2),
      constrs = Fn.NTab.merge_joint (K true) (#constrs rep) (#constrs rep2),
      constcntab = Symtab.merge (K true) (#constcntab rep, #constcntab rep2),
      ctmap = FnTnMap.union_merge (#ctmap rep) (#ctmap rep2)
    }; *)

  
  fun get_dtyps (MData rep) = #dtyps rep;
  fun get_typs (MData rep) = #typs rep;
  fun get_ctmap (MData rep) = #ctmap rep;
  fun get_constrs (MData rep) = #constrs rep;
  fun get_constcntab (MData rep) = #constcntab rep;
  fun get_typtntab (MData rep) = #typtntab rep;

  val get_dtyp = Tn.NTab.get o get_dtyps;
  val get_constr_set = FnTnMap.get_domset o get_ctmap;

  fun update_dtyps f (MData rep) = 
    MData { dtyps = f (#dtyps rep), typs = #typs rep, 
            constcntab = #constcntab rep, constrs = #constrs rep,
            typtntab = #typtntab rep, ctmap = #ctmap rep };
  fun update_typs f (MData rep) = 
    MData { dtyps = #dtyps rep, typs = f (#typs rep), 
            constcntab = #constcntab rep, constrs = #constrs rep,
            typtntab = #typtntab rep, ctmap = #ctmap rep };
  fun update_typtntab f (MData rep) = 
    MData { dtyps = #dtyps rep, typs = #typs rep, 
            constcntab = #constcntab rep, constrs = #constrs rep,
            typtntab = f(#typtntab rep), ctmap = #ctmap rep };
  fun update_constrs f (MData rep) = 
    MData { dtyps = #dtyps rep, typs = #typs rep, 
            constcntab = #constcntab rep, constrs = f(#constrs rep),
            typtntab = #typtntab rep, ctmap = #ctmap rep };
  fun update_constcntab f (MData rep) = 
    MData { dtyps = #dtyps rep, typs = #typs rep, 
            constcntab = f( #constcntab rep), constrs = #constrs rep,
            typtntab = #typtntab rep, ctmap = #ctmap rep };
  fun update_ctmap f (MData rep) = 
    MData { dtyps = #dtyps rep, typs = #typs rep, 
            constcntab = #constcntab rep, constrs = #constrs rep,
            typtntab = #typtntab rep, ctmap = f(#ctmap rep) };

  val set_dtyps = update_dtyps o K;
  val set_typs = update_typs o K;
  val set_typtntab = update_typtntab o K;
  val set_constrs = update_constrs o K;
  val set_constcntab = update_constcntab o K;
  val set_ctmap = update_ctmap o K;

  fun get_constr_dtyp_list_of_tn data tn = 
      let val (NamedDType.Ndtyp ndtab) = get_dtyp data tn
      in (Fn.NTab.list_of ndtab) end;

  fun get_constrs_as_bcs_scs data tn = 
      fold (fn (c,l) => fn (base_cs, rec_cs) => 
            if DataGen.is_rec_elem_list l then (base_cs,(c,l)::rec_cs) 
            else ((c,l)::base_cs,rec_cs))
           (get_constr_dtyp_list_of_tn data tn)
           ([],[]);

  fun const_of_cn data cn = 
      Const(Fn.NTab.get (get_constrs data) cn);

  exception tn_of_typ_exp of string;
  fun tn_of_typ data (Type (n,_)) = 
      (case (Symtab.lookup (get_typtntab data) n) of SOME tn => tn
          | NONE => raise tn_of_typ_exp ("tn_of_typ: not in symtab: " ^ n))
    | tn_of_typ data _ = raise tn_of_typ_exp "tn_of_typ: not const type";

  fun get_dinfo data thy dn = 
      Datatype.get_info thy (fst (Tn.NTab.get (get_typs data) dn));

  fun is_tm_rec_tn d tname = Tn.NTab.contains (get_dtyps d) tname;

  (* pretty printing *) 
  fun pretty_typs ctxt tntab = 
      Tn.NTab.pretty (fn (n,ty) => 
        Pretty.block [Pretty.str n, Pretty.str " = ",  
                      Syntax.pretty_typ ctxt ty]) tntab;

  val pretty_dtyp = NamedDType.pretty;

  fun pretty_dtyps dtntab = Tn.NTab.pretty pretty_dtyp dtntab;

  fun pretty_constrs ctxt constrs = 
      Fn.NTab.pretty (fn x => Syntax.pretty_term ctxt (Const x)) constrs;

  fun pretty_typtntab symtab = 
      Pretty.list "[" "]" (map  
        (fn (tyn,tn) => Pretty.block [Pretty.str tyn, Pretty.str " => ", Tn.pretty_name tn]) 
        (Symtab.dest symtab));

  fun pretty_constcntab symtab = 
      Pretty.list "[" "]" (map  
        (fn (isafn,f) => Pretty.block [Pretty.str isafn, Pretty.str " => ", Fn.pretty_name f]) 
        (Symtab.dest symtab));

  fun pretty_ctmap ctmap = FnTnMap.pretty ctmap;

  fun pretty ctxt (MData rep) = 
    Pretty.chunks 
      [ Pretty.block [Pretty.str "tn->dtyp: ", pretty_dtyps (#dtyps rep)],
        Pretty.block [Pretty.str "tn->typ: ", pretty_typs ctxt (#typs rep)],
        Pretty.block [Pretty.str "typn->tn: ", pretty_typtntab (#typtntab rep)],
        Pretty.block [Pretty.str "c->constr: ", pretty_constrs ctxt (#constrs rep)],
        Pretty.block [Pretty.str "constr->c: ", pretty_constcntab (#constcntab rep)],
        Pretty.block [Pretty.str "c->tn: ", pretty_ctmap (#ctmap rep)]
      ];

  val print = Pretty.writeln oo pretty;

  (* Create the theory data stored in an Isabelle theory *)
  structure ThyData = Theory_Data
  (
    type T = T
    val empty = empty
    val extend = I
    fun merge (t1, t2) = merge (t1, t2)
  );


  val of_ctxt = ThyData.get o ProofContext.theory_of;
  val of_thy = ThyData.get;

  fun dn_infos_of_freevars_in_term data thy t = 
      let 
        val dtyps = get_dtyps data
        val typtntab = get_typtntab data
        val stab = fold (fn (free, Type(n,ty)) => 
                            (case (Symtab.lookup typtntab n) of SOME tn => 
                              if Tn.NTab.contains dtyps tn then 
                              Symtab.update (n,free) else I
                             | NONE => I)
                          | _ => I) 
             (Trm.frees_of t) 
             Symtab.empty
        val info = (map_filter (Datatype.get_info thy) (Symtab.keys stab))
      in info end;

   fun ripple_thms_of_dinfo (info : Datatype.info) = 
       (#inject info) @ (#distinct info) @ (#case_rewrites info);

   fun ripple_thms_of_term data thy t = 
       maps ripple_thms_of_dinfo (dn_infos_of_freevars_in_term data thy t);


  structure Thy = struct
    type ctxt = Context.theory;
    val get_dtyps = get_dtyps o of_thy;
    val get_dtyp = get_dtyp o of_thy;
    val get_typs = get_typs o of_thy;
    val get_constrs = get_constrs o of_thy;
    val get_ctmap = get_ctmap o of_thy;
    val get_typtntab = get_typtntab o of_thy;
    val get_constcntab = get_constcntab o of_thy;

    val is_tm_rec_tn = is_tm_rec_tn o of_thy;
    val ripple_thms_of_term' = ripple_thms_of_term;
    fun ripple_thms_of_term thy = ripple_thms_of_term' (of_thy thy) thy;

    (* print data in theory *)
    val pretty' = pretty;
    fun pretty thy = pretty' (ProofContext.init_global thy) (of_thy thy);
    val print' = print;
    fun print thy = print' (ProofContext.init_global thy) (of_thy thy);
  end;
  
  structure Ctxt = struct
    type ctxt = Proof.context;
    (* print data in theory *)
    val pretty' = pretty;
    fun pretty ctxt = pretty' ctxt (of_ctxt ctxt);
    val print' = print;
    fun print ctxt = print' ctxt (of_ctxt ctxt);
    (* get from isar context / theory *)
    val get_dtyps = get_dtyps o of_ctxt;
    val get_dtyp = get_dtyp o of_ctxt;
    val get_typs = get_typs o of_ctxt;
    val get_ctmap = get_ctmap o of_ctxt;
    val get_constrs = get_constrs o of_ctxt;
    val get_typtntab = get_typtntab o of_ctxt;
    val get_constcntab = get_constcntab o of_ctxt;

    val is_tm_rec_tn = is_tm_rec_tn o of_ctxt;

    val pretty_dtyp' = pretty_dtyp;
    fun pretty_dtyp ctxt tn = pretty_dtyp' (get_dtyp ctxt tn);
    fun print_dtyp ctxt tn = Pretty.writeln (pretty_dtyp ctxt tn);

    fun ripple_thms_of_term ctxt = 
        Thy.ripple_thms_of_term (ProofContext.theory_of ctxt);

    (* all type names *)
    val get_tnset = Tn.NTab.get_nameset o get_typs;
    (* constructed type names (i.e. ones we defined and can recurse on) *)
    val get_ctnset = FnTnMap.get_codset o get_ctmap;
  end

end; (* local open DataGen *)
end; (* struct *)

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(* code to create and hold information about functions; add them to the Isabelle theory etc. *)
structure Fun = struct 
(* local open TM_Types in *)

  (* The data-structure to hold ThoeryMine defined functions. *)
  datatype T = MFun of  
  {
    (* function to term table maps internal function names to 
       list of Isabelle terms that the functions defining equations, the string 
       is the function's Isabelle name, the type its Isabelle type  *)
    fntab : ((string * Term.typ) * term list) Fn.NTab.T,

    (* mapping from Isabelle full function symbol name to internal name (Fn.name) *)
    fsymtab : Fn.name Symtab.table,

    (* function mapped to all functions that use it *)
    fdeps : FnRel.T,

    (* type mapped to all functions that are recursively defined using that type *)
    trec_deps : TnFnRel.T, (* NOTE: until we have mutual rec, this will be map shaped *)

    (* types to functions that result in a value of that type *)
    tres_deps : TnFnRel.T, (* NOTE: until we return pairs, this will be map shaped *)

    (* types to all functions take an input of that type *)
    targ_deps : TnFnRel.T
  }

  val empty = MFun {fntab = Fn.NTab.empty, fsymtab = Symtab.empty, 
                     fdeps = FnRel.empty, 
                     targ_deps = TnFnRel.empty,
                     trec_deps = TnFnRel.empty,
                     tres_deps = TnFnRel.empty
                   };
  
  fun get_fntab (MFun rep) = #fntab rep;
  fun get_fsymtab (MFun rep) = (#fsymtab rep);
  fun get_fdeps (MFun rep) = (#fdeps rep);
  fun get_targ_deps (MFun rep) = (#targ_deps rep);
  fun get_trec_deps (MFun rep) = (#trec_deps rep);
  fun get_tres_deps (MFun rep) = (#tres_deps rep);

  fun update_fntab f (MFun rep) = 
   MFun {fntab = f (#fntab rep), fsymtab = #fsymtab rep, 
         fdeps = #fdeps rep, targ_deps = #targ_deps rep, 
         trec_deps = #trec_deps rep, tres_deps = #tres_deps rep};
  
  fun update_fsymtab  f (MFun rep) = 
   MFun {fntab =  #fntab rep, fsymtab = f (#fsymtab rep), 
         fdeps = #fdeps rep, targ_deps = #targ_deps rep, 
         trec_deps = #trec_deps rep, tres_deps = #tres_deps rep};
  
  fun update_fdeps f (MFun rep) = 
   MFun {fntab =  #fntab rep, fsymtab = #fsymtab rep, 
     fdeps = f(#fdeps rep), targ_deps = #targ_deps rep, 
         trec_deps = #trec_deps rep, tres_deps = #tres_deps rep}; 
  
  fun update_targ_deps f (MFun rep) = 
   MFun {fntab =  #fntab rep, fsymtab = #fsymtab rep, 
     fdeps = #fdeps rep, targ_deps = f(#targ_deps rep),
         trec_deps = #trec_deps rep, tres_deps = #tres_deps rep}; 

  fun update_trec_deps f (MFun rep) = 
   MFun {fntab =  #fntab rep, fsymtab = #fsymtab rep, 
     fdeps = #fdeps rep, targ_deps = #targ_deps rep,
          trec_deps = f(#trec_deps rep), tres_deps = #tres_deps rep}; 

  fun update_tres_deps f (MFun rep) = 
   MFun {fntab =  #fntab rep, fsymtab = #fsymtab rep, 
     fdeps = #fdeps rep, targ_deps = #targ_deps rep,
         trec_deps = #trec_deps rep, tres_deps =  f(#tres_deps rep)}; 
  
  val set_fntab  = update_fntab o K;
  val set_fsymtab  = update_fsymtab o K;
  val set_fdeps  = update_fdeps o K;
  val set_targ_deps  = update_targ_deps o K;
  val set_trec_deps  = update_trec_deps o K;
  val set_tres_deps  = update_tres_deps o K;

  (* get Isabelle string and type from Fn.name of context *)
  val constinfo_of_fname = fst oo (Fn.NTab.get o get_fntab);

  fun rectns_of_fname d fname = TnFnRel.codf (get_trec_deps d) fname;
  fun rectyps_of_fname d dtype_d fname = 
      map (Tn.NTab.get (DType.get_typs dtype_d))
          (Tn.NSet.list_of (rectns_of_fname d fname));
  
  fun is_tm_rec_fn d fname = Fn.NTab.contains (get_fntab d) fname;

  (* n1 is defined using n2 *)
  fun add_fdep n1 n2 mf = 
      update_fdeps (FnRel.add1 n1 n2) mf;

  (*************** Pretty Printing **************)
  fun pretty_defs ctxt ((nm, ty), trms) = 
    Pretty.chunks 
      ([(Pretty.str ("Function name : "^nm^", ")), 
        Pretty.block [Pretty.str "type: ", Syntax.pretty_typ ctxt ty]]
      @ (map (Syntax.pretty_term ctxt) trms));
    
  fun pretty_fntab ctxt fntab =
    Fn.NTab.pretty (pretty_defs ctxt) fntab;
  
  fun pretty_fsymtab symtab =
    Pretty.list "[" "]" (map  
    (fn (tyn,f) => Pretty.block [Fn.pretty_name f, Pretty.str ": ", Pretty.str tyn]) 
    (Symtab.dest symtab));
  
  fun pretty_fdeps fdeps = FnRel.pretty fdeps;
  fun pretty_targ_deps tdeps = TnFnRel.pretty tdeps
  fun pretty_trec_deps tdeps = TnFnRel.pretty tdeps
  fun pretty_tres_deps tdeps = TnFnRel.pretty tdeps

  fun pretty ctxt (MFun rep) = 
      Pretty.chunks  
        [ Pretty.block [Pretty.str "fn->Isa funnm*defs: ", pretty_fntab ctxt (#fntab rep)],
          Pretty.block [Pretty.str "Isa Funnm->fn: ", pretty_fsymtab (#fsymtab rep)],
          Pretty.block [Pretty.str "Fun used by: ", pretty_fdeps (#fdeps rep)],
          Pretty.block [Pretty.str "Type is arg_of: ", pretty_targ_deps (#targ_deps rep)],
          Pretty.block [Pretty.str "Type is rec_of: ", pretty_trec_deps (#trec_deps rep)],
          Pretty.block [Pretty.str "Type is res_of: ", pretty_tres_deps (#tres_deps rep)]
        ];

  val print = Pretty.writeln oo pretty;

  fun merge (MFun rep, MFun rep2) =  MFun rep2
  (* takes second if there is an overlap *)
  (*  MFun { 
      fntab = Fn.NTab.merge_joint (K true) (#fntab rep) (#fntab rep2), 
      fsymtab = Symtab.merge (K true) (#fsymtab rep, #fsymtab rep2), 
      fdeps = FnRel.union_merge (#fdeps rep) (#fdeps rep2),
      targ_deps = TnFnRel.union_merge (#targ_deps rep) (#targ_deps rep2),
      trec_deps = TnFnRel.union_merge (#trec_deps rep) (#trec_deps rep2),
      tres_deps = TnFnRel.union_merge (#tres_deps rep) (#tres_deps rep2) 
    }; *)

  structure ThyData = Theory_Data
    (
      type T = T
      val empty = empty
      val extend = I
      fun merge (t1, t2) = merge (t1, t2)
    );
  val of_thy = ThyData.get;
  val of_ctxt = ThyData.get o ProofContext.theory_of;

  structure Thy = struct 
    type ctxt = theory;
    val get_fntab = get_fntab o of_thy;
    val get_fdeps = get_fdeps o of_thy;
    val get_fsymtab = get_fsymtab o of_thy;
    val get_targ_deps = get_targ_deps o of_thy;
    val get_trec_deps = get_trec_deps o of_thy;
    val get_tres_deps = get_tres_deps o of_thy;
    val constinfo_of_fname = constinfo_of_fname o of_thy;
    val rectns_of_fname = rectns_of_fname o of_thy;

    val is_tm_rec_fn = is_tm_rec_fn o of_thy;

    local val rectyps_of_fname' = rectyps_of_fname; in 
    fun rectyps_of_fname thy fname = 
        rectyps_of_fname' (of_thy thy) (DType.of_thy thy) fname;
    end;

    (* get defining equations (simps) of function name, via function package info *)
    fun defthms_of_fname thy n = 
        let val ctxt = ProofContext.init_global thy; 
          val i = Function.get_info ctxt (Const (constinfo_of_fname thy n)); 
        in the (#simps i) end;

    val pretty' = pretty;
    fun pretty thy = pretty' (ProofContext.init_global thy) (of_thy thy);
    val print = Pretty.writeln o pretty;
  end;

  structure Ctxt = struct 
    type ctxt = Proof.context;
    val get_fdeps = get_fdeps o of_ctxt;
    val get_fntab = get_fntab o of_ctxt;
    val get_fsymtab = get_fsymtab o of_ctxt;
    val get_targ_deps = get_targ_deps o of_ctxt;
    val get_trec_deps = get_trec_deps o of_ctxt;
    val get_tres_deps = get_tres_deps o of_ctxt;
    val constinfo_of_fname = constinfo_of_fname o of_ctxt;
    val rectns_of_fname = rectns_of_fname o of_ctxt;
    val rectyps_of_fname = Thy.rectyps_of_fname o ProofContext.theory_of;

    val is_tm_rec_fn = is_tm_rec_fn o of_ctxt;

    (* get defining equations (simps) of function name, via function package info *)
    fun defthms_of_fname ctxt n = 
        let val i = Function.get_info ctxt (Const (constinfo_of_fname ctxt n)); 
        in the (#simps i) end;

    val pretty' = pretty;
    fun pretty ctxt = pretty' ctxt (of_ctxt ctxt);
    val print = Pretty.writeln o pretty;
  end;  
  (* *)


(* end;  *)
end; (* local; struct *)

local open DType in 
  (* Add a base type *)
  exception not_type_constsant_exp of string;
  fun add_base_type (n,ty as Type(tyn,_)) thy = 
      ThyData.map (update_typs (Tn.NTab.ins (n,(tyn,ty)))
                   o update_typtntab (Symtab.update (tyn, n))) thy
    | add_base_type _ _ = raise not_type_constsant_exp "add_base_type";
  
  (* Adding a simple datatype to a theory
      : string -> MThy.dtyp -> theory -> theory
     name : string name of new datatype (will be changed to avoid clashes)
     MThy.dtyp : datatype representation to be created for the given name
     thy : theory being edited. 
  *)
  fun add_new_datatype suggested_name (DataGen.DType ll) thy =
    let
      val data = ThyData.get thy;
      val typs = get_typs data;
      (* construct names *)
      val tn = Tn.NSet.new (Tn.NTab.get_nameset typs) suggested_name;
      val name = Tn.dest tn;
      val qualified_name = Binding.qualified_name name;
      val full_name = Sign.full_name thy qualified_name;
      (* add new name to the types table, with what will be its Isabelle type *)
      val rec_type = Type (full_name, []);
      val typs = Tn.NTab.doadd (tn, (full_name,rec_type)) typs;
      fun type_of_elem DataGen.Rec = rec_type | type_of_elem (DataGen.Typ n) = snd (Tn.NTab.get typs n);
      (* make constructors and named_dtyp *)
      val (ndtyp as NamedDType.Ndtyp ndtab, constrs, constcntab, ctmap) = 
            fold_rev
            (fn l => fn (NamedDType.Ndtyp ndtab, constrs, constcntab, ctmap) => 
               let val cn = Fn.NSet.new (FnTnMap.get_domset ctmap) Fn.default_constr_name
                   val constr_name = Binding.qualified false (Fn.string_of_name cn) qualified_name;
                   val c_full_name = Sign.full_name thy constr_name;
               in (NamedDType.Ndtyp (Fn.NTab.ins (cn,l) ndtab), 
                   Fn.NTab.ins (cn, (c_full_name, (map type_of_elem l) ---> rec_type)) constrs,
                   Symtab.update (c_full_name, cn) constcntab,
                   FnTnMap.add_to_dom cn tn ctmap)
               end)
            ll
            (NamedDType.Ndtyp Fn.NTab.empty, get_constrs data, get_constcntab data, get_ctmap data);
      val dtyps = Tn.NTab.doadd (tn, ndtyp) (get_dtyps data);
      
    in (* update the theory *) 
      thy
        (* use datatype package of Isabelle *)
        |> Datatype.add_datatype 
              Datatype.default_config
              [name] 
              [([], qualified_name, 
                      NoSyn, 
                      map (fn (cn,Ts) => let val (c_full_name, typ) = Fn.NTab.get constrs cn
                           in (Binding.qualified_name (Long_Name.base_name c_full_name), 
                               fst (Term.strip_type typ), NoSyn) end)
                          (Fn.NTab.list_of ndtab)
                )]
        |> snd (* ignore theorems provided by datatype package *)
        (* update TheoryMine data *)
        |> ThyData.map (
              set_ctmap ctmap
            o set_constrs constrs
            o set_constcntab constcntab 
            o set_typs typs 
            o set_dtyps dtyps 
            o update_typtntab (Symtab.update (full_name, tn))
           )
        |> Fun.ThyData.map (
          I (* FIXME add deps? *)
        )
    end;
  
end (* local *)

exception unkown_function of string; 
local open Fun in 
(*       (Term.dest_Const @{term "op ="},[]) *)
  fun add_isabelle_function ((fname,ty),eqtrms) thy = 
      let val (fname',fntab') = Fn.NTab.add (Fn.mk fname,((fname,ty),eqtrms)) (Thy.get_fntab thy)
          val constcntab = DType.Thy.get_constcntab thy
          val fsymtab = Fun.Thy.get_fsymtab thy
          val fdeps' = 
              fold (fn t => 
                    let val ns = Trm.constnames_of t
                    in 
                        fold (fn n => case Symtab.lookup constcntab n of NONE => 
                                (case Symtab.lookup fsymtab n of NONE => 
                                   raise unkown_function n
                                 | SOME fnn => FnRel.add1 fnn fname')
                              | SOME cn => I)
                             ns
                    end)
                eqtrms
                (Thy.get_fdeps thy)
      in 
        ThyData.map 
          (set_fntab (fntab')
          o update_fsymtab (Symtab.update (fname,fname'))
          o set_fdeps fdeps'
           (* o update_tdeps... ?  FIXME: all type deps *)
          ) thy
      end;
  
  (* Add a (synthesised) function to the theory. 
     Called by MFun.synth_fundefs (see below).
     Arguments: 
       suggested function name (used if fresh, else approximated)   Fn.name -> 
       The parameters used to synthesise this function: MThy.fun_param -> 
       The current theory:                              theory -> 
       Temp function name used during synthesis:        string -> 
       The type of the synthesised function:            typ -> 
       The defining equations:                          term list -> 
     Return: Theory with functions added:               theory
    
    This function also takes care of changing the temporary representation of the fun
    which comes from synthesis (as a Const called `tmp_fname') into
    a Free with a fresh name, to make the defining equations into the form
    where was can used them to `officialy' create the new function.
  *)
  val run_single_threaded = true;

  (* given theory and defining equations *)
  fun add_new_function' funn ((tmp_fname,rec_tn,fun_type),init_eqs) inthy =
  let (* global stuff from theory *)
    val thy = Theory.checkpoint inthy;
    val thy0 = thy;
    val data = ThyData.get thy;
    val dtype_data = DType.ThyData.get thy;
    val fntab = (get_fntab data);

    (* choose a new name for the function that's different from known function names *)
    val fnm = Fn.NSet.new (Fn.NTab.get_nameset fntab) funn;
    val q_fnm = Binding.qualified_name (Fn.dest fnm);
    val fullname = Sign.full_name thy q_fnm;

    (* Change the equations to use the new (fresh) name for the function. 
       Make a copy using Frees is for definition package, 
       the one with Consts is to be stored in fntab (functions to isabelle def details) *)
    val eqs_consts = map (IsaCoSy_SynthFundefs.rename_free_to_const tmp_fname fullname) init_eqs;
    (* for function package treat as free *)
    val eqs_frees = map (IsaCoSy_SynthFundefs.rename_free_to_free tmp_fname (Fn.dest fnm)) init_eqs;

    val (arg_typs,result_type) = Term.strip_type fun_type;

    (* find all constant symbols used in def *)
    val funs_used_in_def = 
        Fn.NSet.of_list ((maps Trm.constnames_of eqs_frees)
                            |> map_filter (Symtab.lookup (get_fsymtab data)));
  in (fnm,
      (NONE,
        (*Theory_Target.init NONE thy *)
        Named_Target.theory_init thy (* The above doesn't exist in 2011, hope changed to right new one*)
        |> (* FIXME: HACK! because for some cases fun package loops forever, and even crashes ML;
              thus limit it to 5 seconds (hopefully too short for it to terminally die) *)
           (* KINDA-FIXED: fiddled with Isabelle, thanks to Alexander Krous. 
              TimeLimit.timeLimit (Time.fromSeconds 2) *)
           (Function_Fun.add_fun
             (* names for multually defined functions *)
             [(q_fnm, NONE, NoSyn)]
             (* names/attributes for defining theorems *)
             (map (fn t => ((Binding.qualified_name "", []), t)) eqs_frees)
             (* function package config *)
             Function_Common.default_config)
       (*  |> Local_Theory.exit *)
        |> ProofContext.theory_of
        |> ThyData.map 
            (update_fntab (Fn.NTab.update (fnm, ((fullname, fun_type), eqs_consts)))
              o update_fsymtab (Symtab.update (fullname,fnm))
              o update_fdeps (FnRel.add_to_dom fnm funs_used_in_def)
              o update_targ_deps (fold (fn typn => 
                  TnFnRel.add1 (DType.tn_of_typ dtype_data typn) fnm) arg_typs)
              o update_trec_deps (TnFnRel.add1 rec_tn fnm)
              o update_tres_deps (TnFnRel.add1 (DType.tn_of_typ dtype_data result_type) fnm)
            )
      ) handle TimeLimit.TimeOut => (SOME "Timeout", thy0)
             | ERROR m => (SOME ("ERROR:" ^ m), thy0))
  end;

(* 
(Const("Trueprop", Type("fun", [Type("bool", []), Type("prop", [])]))) $
 (((Const("op =", Type("fun", [Type("DType.mw", []), Type("fun", [Type("DType.mw", []), Type("bool", [])])]))) $
 (((Free("mwf", Type("fun", [Type("DType.mw", []), Type("fun", [Type("DType.mw", []), Type("DType.mw", [])])]))) $
 (((Const("DType.mw.Ca", Type("fun", [Type("bool", []), Type("fun", [Type("bool", []), Type("DType.mw", [])])]))) $
 (Free("b1", Type("bool", [])))) $
 (Free("b2", Type("bool", []))))) $
 (Free("y", Type("DType.mw", []))))) $
 (Free("y", Type("DType.mw", [])))) 
*)
 
  exception not_a_good_defining_equation_exp of string;

  (* helper to get sides of HOL eq. *)
  fun termpair_of_defining_eq
        ((Const("Trueprop", Type("fun", [Type("bool", []), Type("prop", [])]))) $
          ((((Const("op =", Type("fun", [ty1, Type("fun", [ty2, Type("bool", [])])])))) $ lhs) $ rhs)) = (lhs,rhs)
    | termpair_of_defining_eq _ = raise not_a_good_defining_equation_exp "not equation shaped";

  (* helper function to get the function name, recursive argument type, and function type, 
     from a defining equation *)
  fun info_of_defining_eq thy 
        ((Const("Trueprop", Type("fun", [Type("bool", []), Type("prop", [])]))) $
          ((((Const("op =", Type("fun", [ty1, Type("fun", [ty2, Type("bool", [])])])))) $ lhs) $ rhs)) = 
      let val (f,args) = Term.strip_comb lhs in
        (case f of Free(name,ty) =>   
          (case Library.get_first (* argument function is recursive on (arg with at head) *)
                  (fn t => case Term.strip_comb t 
                             of (Const(c,ty),_) => SOME (fastype_of t) | _ => NONE)
                  args
             of SOME (Type(typ_nm,[])) => (name, typ_nm, ty)
              | NONE => raise not_a_good_defining_equation_exp "no rec argument in lhs")
         | _ => raise not_a_good_defining_equation_exp "lhs head not a Free")
      end
    | info_of_defining_eq _ _ = raise not_a_good_defining_equation_exp "not equation shaped";

  (* given theory and defining equations *)
  (* FIXME: think more about name clashes; and preserving the name we are given *)
  fun add_new_function funn init_eqs thy = 
      let 
        val (fname,rec_on_tynm,typ) = info_of_defining_eq thy (hd init_eqs);
        (* lookup the ThoeryMine internal type name (of type Tn.name) *)
        val rec_tn = the (Symtab.lookup (DType.Thy.get_typtntab thy) rec_on_tynm);
      in add_new_function' funn ((fname,rec_tn,typ),init_eqs) thy end;


  (* Function construction parameters *)
  datatype fun_param =
           FunParams of
           {rec_tynm : Tn.name, (* type this function is recursive on *)
            arg_tynms : Tn.name list, (* other arguments used *)
            result_tynm : Tn.name, (* result type *)
            cparams : ConstraintParams.T, (* *)
            size : int}; (* max size of RHS *)

  fun get_rec_tynm (FunParams rep) = #rec_tynm rep;
  fun get_arg_tynms (FunParams rep) = #arg_tynms rep;
  fun get_result_tynm (FunParams rep) = #result_tynm rep;
  fun get_maxsize (FunParams rep) = #size rep;
  fun get_cparams (FunParams rep) = #cparams rep;
(*  fun get_all_types (FunParams rep) = #all_types rep;

            all_types : Tn.NSet.T, (* All types used in this synthesis attempt. Including
                                      types used by the function we're synthesising, and
                                      types used by any function in the avail_funs set. *)
*)

  (* Interface to IsaCoSy_SynthFundefs.synth_fundef. Arguments that need to be passed to 
     synthesis are wrapped in the `funparam' datatype (see type def: MThy.FunParams). 
     updates the theory. 
  *)
  (* IMPROVE? fix order of args to standard const-style for funinfo ? *)
  fun synth_funs thy funparams =
  let 
    val ctxt = ProofContext.init_global thy;

    (* Temporary name used during synthesis *)
    (* FIXME: this is a hack to avoid synth making either const or free that 
       clashes with an existing name/future name. *)
    val default_funnm = "_f"; 

    (* theory/global data *)
    val type_data = DType.ThyData.get thy;
    val types_tab = DType.get_typs type_data; (* TM Datatype data *)
    val data = ThyData.get thy; (* TM Function data *)
    
    val (rec_tyname, rec_typ) = Tn.NTab.get types_tab (get_rec_tynm funparams); 
    val other_args = map (snd o Tn.NTab.get types_tab) (get_arg_tynms funparams);
    val (result_tyname,result_type) = Tn.NTab.get types_tab (get_result_tynm funparams);

    (* Add these: They are lists of pairs (constructor-name, type) *)   
    val (base_constrs, rec_constrs) = 
        (DType.get_constrs_as_bcs_scs type_data (get_rec_tynm funparams))
        |> (fn (bs,cs) => (map (fn (cn,l) => (DType.const_of_cn type_data cn)) bs, 
                           map (fn (cn,l) => (DType.const_of_cn type_data cn)) cs));

    val max_size = get_maxsize funparams;
    
    val fun_info = 
        (default_funnm, get_rec_tynm funparams, ((rec_typ::other_args)--->result_type));

  (* Synthesise a bunch of function defintions, and add them to the theory. *)
  in map (fn x => (fun_info,x))
    (IsaCoSy_SynthFundefs.synth_fundef (base_constrs, rec_constrs, rec_typ)
            other_args result_type max_size default_funnm ctxt (get_cparams funparams))
  end;
      


end (* local Fun *)
end; (* TM_Data *)

local structure Check_TM_Data : TM_DATA = TM_Data in val _ = () end;
