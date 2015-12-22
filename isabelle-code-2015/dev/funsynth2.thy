theory funsynth2
imports tm_initial
begin

ML {*
(* construct function synthesis params for a level1 function (defined only in terms of datatype) 
   given context, type and number of args *)
fun level1_funparam_seq_of_datatype ctxt rec_tynm nargs =
    let val nset = (TM_Data.DType.Ctxt.get_tnset ctxt);
        val thy = (ProofContext.theory_of ctxt);
        val cparams = 
            ConstraintParams.empty 
              |> ThyConstraintParams.add_eq ctxt
              |> ThyConstraintParams.add_datatype ctxt 
                  (fst (Tn.NTab.get (TM_Data.DType.Ctxt.get_typs ctxt) rec_tynm));
    in 
    (* Seq of element lists upto nargs + 1 (+1 to include result type) *)
      (DataGen.suc_seq (DataGen.nr_elem_list_suc' nset)
        (the (DataGen.nr_mk_bot_elem_list nset (nargs + 1))))
      |> Seq.map (map (fn DataGen.Typ x => x))
      |> Seq.map
         (fn (result_tynm::arg_tynms) =>
          TM_Data.FunParams {
            rec_tynm = rec_tynm, (* type this function is recursive on *)
            arg_tynms = arg_tynms, (* other arguments used *)
            result_tynm = result_tynm, (* result type *)
            cparams = cparams, (* basic constraints *)
            size = 12
           })
    end;
*}


ML {*
  val funparam_seq = level1_funparam_seq_of_datatype @{context} (Tn.mk "T_1") 1;
  val funparam = Seq.hd funparam_seq;

  val thy = @{theory};
local open TM_Data; open Fun in 
   (* theory/global data *)
    val type_data = DType.ThyData.get thy;
    val types_tab = DType.get_typs type_data; (* TM Datatype data *)
    val data = ThyData.get thy; (* TM Function data *)
    
    val (rec_tyname, rec_typ) = Tn.NTab.get types_tab (get_rec_tynm funparam); 
    val other_args = map (snd o Tn.NTab.get types_tab) (get_arg_tynms funparam);
    val (result_tyname,result_type) = Tn.NTab.get types_tab (get_result_tynm funparam);

    (* Add these: They are lists of pairs (constructor-name, type) *)   
    val (base_constrs, rec_constrs) = 
        (DType.get_constrs_as_bcs_scs type_data (get_rec_tynm funparam))
        |> (fn (bs,cs) => (map (fn (cn,l) => (DType.const_of_cn type_data cn)) bs, 
                           map (fn (cn,l) => (DType.const_of_cn type_data cn)) cs));

    val max_size = get_maxsize funparam;
    
    val fun_info = 
        (get_rec_tynm funparam, ((rec_typ::other_args)--->result_type));
end;
*}


ML {*

fun add1_free_param typ (t', paramtab)= 
    let val (fresh_nm,ptab) = Trm.TrmParams.add1 ("a",typ) paramtab
    in (t'$Free(fresh_nm,typ), ptab) end;

(* Takes a constant and builds a term with the constant applied
   to appropriate number of arguments as free-variables. *)
fun add_free_params t =
      let val (argtyps,_) = Term.strip_type (Term.fastype_of t);
      in fold add1_free_param argtyps (t,Trm.params_of t) end;

fun gen_lhs (base_dtype_constrs, rec_dtype_constrs,rec_arg_type) 
            other_arg_types return_type fun_nm = 
    let 
      (* We assume we're given a list of constants (Term.Const), which represent
         the constructors of the datatype we're supposed to recurse over *)
      val base_constr_trms = (map (fst o add_free_params) base_dtype_constrs)
      val rec_constr_trms = (map add_free_params rec_dtype_constrs)
      (* val (ty_varnm, ienv) = InstEnv.new_uninst_tvar (("a",0),[]) ienv0 *)
      val fun_typ =  (rec_arg_type::other_arg_types) ---> return_type 
      (* rec_arg_type::other_arg_types ---> TVar(ty_varnm,[]) *)
      val fun_const = Const(fun_nm, fun_typ)
      val base_cases = map (fn constr => fun_const$constr) base_constr_trms
      val rec_cases = map (fn (constr,params) => (fun_const$constr,params))
                          rec_constr_trms
    in
      (fun_typ, 
       map (fn t => fst (fold add1_free_param other_arg_types (t,Trm.params_of t))) base_cases,
       map (fn (t,params) => (fst (fold add1_free_param other_arg_types (t,Trm.params_of t)), 
                              params)) 
           rec_cases)
    end;

*}

ML {*
val (ty,bcs,scs) = gen_lhs (base_constrs, rec_constrs, rec_typ) other_args result_type "f"
*}




ML {*
*}

ML {*
*}

ML {*
*}

end;
