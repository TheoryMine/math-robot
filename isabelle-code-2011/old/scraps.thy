
ML {* 
local open MThy in

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

(* Function construction parameters *)
datatype fun_param =
         FunParams of
         {rec_tynm : Tn.name,
          arg_tynms : Tn.name list,
          res_tynm : Tn.name,
          avail_funs : Fn.NSet.T, (* Names of other funs that synthesis may use *)
          all_types : Tn.NSet.T, (* All types used in this synthesis attempt. Include
                                   types used by the function we're synthesising, and
                                  types used by any function in the avail_funs set.*)
          thrms : Thm.thm list, (* Theorems to generate constraints from, during fun synthesis.*)
          size : int}; (* max size of RHS *)

fun get_rec_tynm (FunParams rep) = #rec_tynm rep;
fun get_arg_tynms (FunParams rep) = #arg_tynms rep;
fun get_res_tynm (FunParams rep) = #res_tynm rep;
fun get_maxsize (FunParams rep) = #size rep;
fun get_avail_funs (FunParams rep) = #avail_funs rep;
fun get_all_types (FunParams rep) = #all_types rep;
fun get_constr_thrms (FunParams rep) = #thrms rep;

end;

*}