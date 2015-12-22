(* Code for synthesising function definions for VTP. *)

signature ISACOSY_SYNTH_FUNDEFS = sig
 val synth_fundef :
     Trm.T list (* base case constructors *)
      * Trm.T list (* step case constructors *)  
      * typ (* type of the recursive datatype *)
     -> typ list (* other argument types *)
     -> typ (* return type *)
     -> int (* max size of rhs *)
     -> string (* temporary function name *)
     -> Proof.context (* proof context *)
     -> ConstraintParams.T (* constraint params *)
     -> term list list (* each sublist is a list of equations that define a function *)
end;

(* *)
structure IsaCoSy_SynthFundefs =
struct
local open SynthNames; open ConstrSynthesis in


(* Instantiate hole with the constant in cinfo, checking if we have
   indeed used the recursive function-constant for which the term we are
   synthesising is the RHS of the recursive case.*)
fun rhs_inst_hole_with_const (rec_fun_nm, used) sterm hole cinfo =
    let 
      val used2 = if used then used 
                  else Constant.name_eq (rec_fun_nm, 
                                          Constraints.get_name cinfo)
    in
      Seq.map (fn strm => (used2,strm))
              (inst_hole_with_const sterm hole cinfo)
    end;

(* Instantiates hole with some vars from the paramtab lhs_frees,
   namely the variables occuring in the LHS of the function definition. *)
fun rhs_inst_hole_with_var used lhs_frees sterm hole =
    let
      fun inst_hole_var frees_ptab strm hole =
          let 
            val typ = get_hole_type strm hole;
			      val synth_trm = get_term strm;
            val constr_tab = get_constrTab strm;
			      val hole_constr_tab = get_holeConstrs strm;
			      val allowed_tab = get_allowedTab strm;
			      val constr_dep_tab = get_constrDepTab strm;
            (* Constraints on this hole *)
			      val hole_constrs = 
					      case (Hole.NTab.lookup hole_constr_tab hole) of
						      NONE => [] | SOME cs => Constraint.NSet.list_of cs;
            val frees = (Trm.TrmParams.get_plist lhs_frees)
										|> map (fn (nm,ty) => Free(nm,ty));
            val forbidden_frees = 
					      map_filter (lookup_forbidden_vars hole constr_tab) hole_constrs;
            val allowed_frees = fold (Library.remove (fn (v1,free) => fst (Term.dest_Free free) = v1))
															       forbidden_frees frees;
			      val hole_trm = Trm.mk_var (Hole.dest hole,typ);
            fun unify_frees_w_hole free_var_trms = 
					      (Seq.of_list free_var_trms)
						      |> Seq.maps (fn freevar => 
														      MyUnify.unifiers (get_ienv strm, 
																							      [(hole_trm, freevar)]))
						      |> Seq.map (fn ienv => 
													       (ienv, InstEnv.inst_trm ienv synth_trm))
			      val frees_unifiers = unify_frees_w_hole allowed_frees
			      val remaining_holes = Library.remove Hole.name_eq hole (get_holes_agenda strm)
            fun update_strm is_fresh (ienv, trm) = 
						    let 
							    val (inst_ty, inst_trm) = InstEnv.get_var_inst ienv (Hole.dest hole)
							    val (free_nm, free_typ) = Term.dest_Free inst_trm
							    val (nw_hctab, nw_ctab, nw_atab, nw_cdtab) = 
									    update_var_constrs hole (free_nm, free_typ)
																		     (hole_constr_tab, constr_tab, 
																			    allowed_tab, constr_dep_tab)
						    in
							    Sterm{term = trm, 
										    ienv = ienv,
										    holes_agenda = remaining_holes,
                        hole_sizes = get_hole_sizes strm,
										    allowedTab = nw_atab,
										    constrTab = nw_ctab,
										    holeConstrs = nw_hctab,
										    constrDepTab = nw_cdtab,
										    max_vars = if is_fresh then (get_max_vars strm) - 1 
										               else (get_max_vars strm)}
						    end 
		      in
			      Seq.map (update_strm false) frees_unifiers
		      end;
	
    in
      Seq.map (fn strm => (used, strm))
              (inst_hole_var lhs_frees sterm hole)
    end;

(* synth_case_fun is a function which we recurse with, which is different depending on
   if called from a base-case or step-case. *)
fun synth_hole synth_case_fun nw_fun_nm holes lhs_frees cinfoTab (sterm,used_f) =
    case holes 
		 of [] => Seq.single sterm
      | (hole::hs) => 
        let 
          val size = get_hole_size sterm hole
				in 
          if (size = 1)
				  then 
					  let 
							val const_infos = 
									(allowed_consts_of_hole sterm hole)
										|> map (the o (Constant.NTab.lookup cinfoTab))
										|> filter (fn cinfo => 
																	(Constraints.get_minsize cinfo) = size)
                  
							val const_insts = 
									(Seq.of_list const_infos) 
										|> Seq.maps (rhs_inst_hole_with_const (nw_fun_nm, used_f) 
                                                          sterm hole)
              val all_insts =
                  const_insts
                    |> Seq.append (rhs_inst_hole_with_var used_f lhs_frees 
                                                          sterm hole) 
						in
              Seq.maps (synth_case_fun lhs_frees cinfoTab) all_insts
            (* Seq.maps (synthesise_rhs (nw_fun_nm,size) lhs_frees cinfoTab)  all_insts *)
						end
          else
					  let
						  val const_infos = 
								  (allowed_consts_of_hole sterm hole)
									  |> map (the o (Constant.NTab.lookup cinfoTab))         
									  |> filter (fn cinfo => 
																	1 < (Constraints.get_minsize cinfo) andalso 
                                  (Constraints.get_minsize cinfo) <= size)
								    
					  in
						  (Seq.of_list const_infos)
							  |> Seq.maps (rhs_inst_hole_with_const (nw_fun_nm, used_f) 
                                                      sterm hole)
							  |> Seq.maps (synth_case_fun lhs_frees cinfoTab) 
					  end
        end;

(* Synthesise a  rhs of a definition, for the function called
   nw_fun_nm. used_f is a boolean which tells us if we have used the function,
   which has to be done as this represents a recursive case. *)
fun synthesise_rhs_rec (nw_fun_nm, fun_size) lhs_frees cinfoTab (used_f, sterm) = 
    let 
      fun get_max [] m = m
        | get_max (size::t) m = if size > m then get_max t size
                                              else get_max t m
      val holes = get_holes_agenda sterm
      val largest_hole = get_max (map (get_hole_size sterm) holes) 0                          
    in 
      (* Check we fit in the things we still need*)
      if ((not used_f) andalso (largest_hole < fun_size))
      then Seq.empty (* failed to use nw_fun_nm, that must be used *)
      else 
        synth_hole (synthesise_rhs_rec (nw_fun_nm, fun_size)) nw_fun_nm 
                                       holes lhs_frees cinfoTab (sterm, used_f)
    end; 
fun synthesise_rhs_base nw_fun_nm lhs_frees cinfoTab (used_f, sterm) = 
    synth_hole (synthesise_rhs_base nw_fun_nm) nw_fun_nm 
               (get_holes_agenda sterm) lhs_frees cinfoTab (sterm, true);

fun start_synth_rec_rhs nw_fun_nm top_const free_vars_of_lhs constInfoTab synth_terms =
    let
      val used_f = Constant.name_eq (top_const,nw_fun_nm)
      val rec_cinfo = the (Constraints.lookup_const constInfoTab nw_fun_nm)
		in
		  (Seq.of_list synth_terms)
 			|> Seq.maps (fn strm => 
                      (synthesise_rhs_rec (nw_fun_nm, Constraints.get_minsize rec_cinfo) 
                                          free_vars_of_lhs 
                                          constInfoTab (used_f,strm)))
			|> Seq.map get_term
      |> Seq.list_of
		end;

(* Differs from above, for the base cases, we don't want to use new_f_nm, so 'used' is set
   to true. We also want to have the right-hand sides which only contains a variable. *)
fun start_synth_base_rhs nw_fun_nm top_const lhs_frees cinfoTab synth_terms =
		(Seq.of_list synth_terms)
 			|> Seq.maps (fn strm => 
                      synthesise_rhs_base nw_fun_nm lhs_frees cinfoTab (true,strm))
      |> Seq.map get_term
			|> Seq.list_of    
     (* (map (fn (nm,ty) => Free(nm,ty)) (Trm.TrmParams.get_plist lhs_frees)) @ lh_sides *)
		;

(* Synthesise a recursive and non-recursive RHS *)
fun init_sterms (top_const, top_cinfo) max_size max_vars ctxt  = 
    let 
      val top_cnstrs = Constraints.get_constrTab top_cinfo
      val (init_trm, init_holes, ienv, allowed_tab1) = 		
					mk_new_term_bit top_cinfo (Hole.NTab.empty) (InstEnv.init ctxt)                  
      val hole_nms_typs = map (fn (nm,ty) => (Hole.mk nm, ty)) init_holes
      val hole_nms = map fst hole_nms_typs;
      val init_constr_tab = Constraint.NTab.useup_names (Constraint.NTab.get_nameset top_cnstrs) 
																									Constraint.NTab.empty
			val constr_renamings = (rename_constraints top_cnstrs init_constr_tab)
														 |> Constraint.nmap_of_renaming				
			val constr_dep_tab1 = 
					init_constr_dep_tab constr_renamings top_cnstrs
			(* Add renamed constraints to the constraint-table and to the table 
         of constraints for each hole *)
			val (hole_constr_tab, constr_tab, allowed_tab, constr_dep_tab) = 
					List.foldl (attach_constr top_cnstrs constr_renamings (map fst hole_nms_typs))
								(Hole.NTab.empty, init_constr_tab, allowed_tab1, constr_dep_tab1) 
								(map snd (Constraints.get_start_constrs top_cinfo))			
			val commute_opt = Constraints.get_commute_opt top_cinfo
			val synth_terms = 
					map (fn holesizes =>
									Sterm {term = init_trm,
												 ienv = ienv,
												 allowedTab = allowed_tab,
												 constrTab = constr_tab,
												 holeConstrs = hole_constr_tab,
												 constrDepTab = constr_dep_tab,
												 holes_agenda = hole_nms,
                         hole_sizes = holesizes,
												 max_vars = max_vars})
							((hole_size_combos commute_opt hole_nms (max_size -1))
                 |> map (fn l => (fold Hole.NTab.ins l Hole.NTab.empty)))
    in
      synth_terms
    end;



(* --- Synthesise a term with a given top symbol (top_fnmae).  --- *)

(* rec_fname is the name of the constant we're trying to define,
   top_fname is the name of the symbol we use at the top-level at the RHS *)
(* synth_case_fun is a function which will synthesise either a recurive or a base case. *)
fun synthesise_f_rhs top_fname max_size free_vars_lhs max_vars ctxt0 
                         constInfoTab synth_case_fun =
    let 
      val top_const = Constant.mk top_fname
      val top_cinfo = case (Constraints.lookup_const constInfoTab top_const) of
                        SOME cinfo => cinfo
                        | NONE => raise ERROR "synthesise_f_term: top-constant not in constInfoTab."
      val top_const_minsize = Constraints.get_minsize top_cinfo
    in
			List.foldl (fn (this_size, terms) => 
										 let   
                       val init_sterms = 
                           init_sterms (top_const, top_cinfo) this_size max_vars ctxt0              
											 val cand_strms = 
													 synth_case_fun top_const free_vars_lhs constInfoTab init_sterms
                     in 
                       terms @ cand_strms (* (map get_term cand_strms) *)
                     end)
	               [] (top_const_minsize upto max_size)
    end;


(********-----  Construct left-hand sides -----*******)

fun mkfree typ (t', paramtab)= 
    let val (fresh_nm,ptab) = Trm.TrmParams.add1 ("a",typ) paramtab
    in (t'$Free(fresh_nm,typ), ptab) end;

(* Takes a constant and builds a term with the constant applied
   to appropriate number of arguments as free-variables. *)
fun build_simple_constructor_term t =
    case t of Const(_,ty) => 
      let val (argtyps,_) = Term.strip_type ty       
      in fold mkfree argtyps (t,Trm.params_of t) end
    | _ => raise ERROR "build_simpl_contructor_term: Expecting to get a constant.";

fun gen_lhs (base_dtype_constrs, rec_dtype_constrs,rec_arg_type) 
            other_arg_types return_type fun_nm = 
    let 
      (* We assume we're given a list of constants (Term.Const), which represent
         the constructors of the datatype we're supposed to recurse over *)
      val base_constr_trms = 
          (map build_simple_constructor_term base_dtype_constrs)
            |> map fst
      val rec_constr_trms = 
           (map build_simple_constructor_term rec_dtype_constrs)
            |> map fst
      (* val (ty_varnm, ienv) = InstEnv.new_uninst_tvar (("a",0),[]) ienv0 *)
      val fun_typ =  (rec_arg_type::other_arg_types) ---> return_type 
      (* rec_arg_type::other_arg_types ---> TVar(ty_varnm,[]) *)
      val fun_const = Const(fun_nm, fun_typ)
      val base_cases = map (fn constr => fun_const$constr) base_constr_trms
      val rec_cases = map (fn constr => fun_const$constr) rec_constr_trms
    in
      (fun_typ, 
       map (fn t => fold mkfree other_arg_types (t,Trm.params_of t)) base_cases,
       map (fn t => fold mkfree other_arg_types (t,Trm.params_of t)) rec_cases)
    end;


(* Little library functions for pairing up constructors *)
fun insert_in_each x [] = []
  | insert_in_each x (l1::ls) = (x::l1)::(insert_in_each x ls);
fun one_from_each []  = [] 
  | one_from_each [[]]  = []
  | one_from_each l = fold (fn l => fn acc => maps (fn x => insert_in_each x acc) l) l [[]]


    (* IMPROVE: dangerous ugly renaming code! *)
  fun rename_free_to_free oldnm newnm t = 
    case t of
      Free(nm,ty) => if (nm=oldnm) then Free(newnm,ty) else Free(nm,ty)
    | t1$t2 => (rename_free_to_free oldnm newnm t1)$(rename_free_to_free oldnm newnm t2)
    | Abs(s,ty,t1) => Abs(s,ty, rename_free_to_free oldnm newnm t1)
    | t1 => t1;

  fun rename_free_to_const oldnm newnm t = 
    case t of
      Free(nm,ty) => if (nm=oldnm) then Const(newnm,ty) else Free(nm,ty)
    | t1$t2 => (rename_free_to_const oldnm newnm t1)$(rename_free_to_const oldnm newnm t2)
    | Abs(s,ty,t1) => Abs(s,ty, rename_free_to_const oldnm newnm t1)
    | t1 => t1;

  fun rename_const_to_free oldnm newnm t = 
    case t of
      Const(nm,ty) => if (nm=oldnm) then Free(newnm,ty) else Const(nm,ty)
    | t1$t2 => (rename_const_to_free oldnm newnm t1)$(rename_const_to_free oldnm newnm t2)
    | Abs(s,ty,t1) => Abs(s,ty, rename_const_to_free oldnm newnm t1)
    | t1 => t1;
  
  fun rename_const_to_const oldnm newnm t = 
    case t of
      Const(nm,ty) => if (nm=oldnm) then Const(newnm,ty) else Const(nm,ty)
    | t1$t2 => (rename_const_to_const oldnm newnm t1)$(rename_const_to_const oldnm newnm t2)
    | Abs(s,ty,t1) => Abs(s,ty, rename_const_to_const oldnm newnm t1)
    | t1 => t1;

(* ------ Build candidate function definitions --------- *)
(*
val synth_fundef :
Triple of base-constructors (as Const),
 recursive constructors, type (the type to rec on):   Trm.T list * Trm.T list * typ ->   
Ordered list of non-rec arguments:               typ list -> 
Desired return type of function:                 typ -> 
Maximal size of RHS:                             int -> 
Temporary function name (during synthesis)       string ->
Current theory:                                  theory -> 
Initial ConstInfoTab:                            Constraints.ConstInfoTab -> 
   (Must contain all constructors of the types we want the function to use,
    as well as all functions we want it to be able to use.)

Returns base and step cases:                     term list list * term list list 
Returns: pair of lists (base-cases,step-cases). 
Each sublist represent a different constructor
*)
fun synth_fundef (base_dtype_constrs, rec_dtype_constrs, type_of_dtype) 
                 other_arg_types return_type max_size_rhs tmp_funnm ctxt 
                 cparams = 
    let 
      (*Construct LH sides. lh_sides are a (term,paramtab) pair, where the paramtab 
        specifies which Frees' have been used in the LHS.  *)
      val (funty, base_lh_sides, rec_lh_sides) = 
          (gen_lhs (base_dtype_constrs, rec_dtype_constrs, type_of_dtype) 
                   other_arg_types return_type tmp_funnm)

      (* all possible top constants (including ) *)
      val ienv = (InstEnv.init ctxt);
      fun correct_top_typ ty = 
          let val (_,const_result_typ) = Term.strip_type ty
          in (Constraints.typ_unify_check return_type ty ienv) end;

      (* IMPROVE: why not just set meta-var at top of the right type and let normal synth 
         algorithm do this for us? *)
      (* make base cases *)
      val base_top_consts = 
          cparams 
            |> ConstraintParams.get_consts 
            |> Symtab.dest 
            |> map_filter (fn (const_nm,const_typ) => if correct_top_typ const_typ
                              then SOME const_nm
                              else NONE);
      
      val base_constInfoTab = Constraints.init ctxt cparams;
  
      val base_cases = 
        map (fn (lhs,paramtab) => 
                let val rhsides = 
                        maps (fn top_const => 
                                 synthesise_f_rhs top_const max_size_rhs 
                                                  paramtab 0 ctxt base_constInfoTab
                                                  (start_synth_base_rhs(Constant.mk tmp_funnm)))
                             base_top_consts
                    val rhs_just_var = 
                        map_filter (fn (nm,ty) => 
                                       if (Constraints.typ_unify_check return_type ty (InstEnv.init ctxt))
                                       then SOME (Free(nm,ty))
                                       else NONE) (Trm.TrmParams.get_plist paramtab)
                in
                  map (fn rhs => HOLogic.mk_eq (lhs,rhs) 
                                  |> HOLogic.mk_Trueprop 
                                  |> rename_const_to_free tmp_funnm tmp_funnm)
                      (rhs_just_var @ rhsides)
                end)
              base_lh_sides

      (* make recursive cases *)
      val rec_top_consts = if correct_top_typ funty 
                           then tmp_funnm::base_top_consts else base_top_consts;
      
      val rec_constInfoTab = 
          cparams 
            |> ConstraintParams.add_const (tmp_funnm,funty)
            (* add lhs as constraints: don't generate trivially loopy and or reducing functions. *)
            |> ConstraintParams.add_termrws ctxt 
                (map (fn (t,paramtab) => (Trm.change_frees_to_fresh_vars t, 
                                          (* HOLogic.true_const *)
                                          @{const "HOL.True"}))
                     (base_lh_sides @ rec_lh_sides))
            |> Constraints.init ctxt;

      val rec_cases =
        map (fn (lhs,paramtab) => 
                let 
                    val rhsides = maps (fn top_const => 
                             synthesise_f_rhs top_const max_size_rhs 
                               paramtab 0 (* 0 = max_vars: no fresh vars on rhs! *)
                               ctxt rec_constInfoTab
                               (start_synth_rec_rhs (Constant.mk tmp_funnm)))
                           rec_top_consts;
                in map (fn rhs => HOLogic.mk_eq (lhs,rhs) 
                                  |> HOLogic.mk_Trueprop
                                  |> rename_const_to_free tmp_funnm tmp_funnm)
                       rhsides
                end) rec_lh_sides

    in
      (* Each list produced is a function definition.
         We compute all combinations of cases for each constructor. 
         Might want to filter out functions where all cases ignore
         one argument, as they will be equivalent to simpler ones. 
         *)
      one_from_each (rec_cases @ base_cases)
    end;

end (* local *)
end;

local structure CheckIsaCoSy_SynthFundefs : ISACOSY_SYNTH_FUNDEFS 
  = IsaCoSy_SynthFundefs; in val _ = (); end;
