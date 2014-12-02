header{* Isabelle code to call IsaCoSy, and store theorems.*}
theory TM_Thms 
imports MakeFun
begin

ML{*
structure MThm = 
struct local open TM_Types in

  (* Data-structure to hold theorems. *)
  datatype T = MThm of {
  (* Functions -> Theorem Names ? *)
  (* Theorem Names -> Proofs *)
  (* What else? *)
  }

  val eq_const = ("op =", Sign.the_const_type thy "op =")
  val reflexive_thm = PureThy.get_thm thy "IsaPHOLUtils.IsaP_reflexive"
  val eq_commute_thm = PureThy.get_thm thy "IsaPHOLUtils.IsaP_eq_commute"

  datatype IsaCoSyParams = 
  ICSParams{functions : Fn.NSet,
            datatypes : Tn.NSet,
            thrms : Thm.thm list,
            min_size : int,
            max_size : int,
            max_vars : int}

  fun get_functions (ICSParams rep) = #functions rep;
  fun get_datatypes (ICSParams rep) = #datatypes rep;
  fun get_thrms (ICSParams rep) = #thrms rep;
  fun get_minsize (ICSParams rep) = #min_size rep;
  fun_get_maxsize (ICSParams rep) = #max_size rep;
  fun_get_maxvars (ICSParams rep) = #max_vars rep;


  (* What do we need to store ? *)
  fun add_thrms (conjs,thrms) thy =
  (* thrms is a pair thm * proofPlan *)

  
  (* Make an initial constant info table for the given 
     functions- and datatypes. Constraints are also generated
     from the given theorems. Tries to do an AC-check as well.
     
    Remember that you have to add even = now, plus any utility
    theorems you need !          
  *)
  
  (* You're probably going to want to add the following to your initial 
     constInfo *)
  val eq_fun = (("op =", Sign.the_const_type thy "op ="), []);
  val reflexive_thm = PureThy.get_thm thy "IsaPHOLUtils.IsaP_reflexive"
  val eq_commute_thm = PureThy.get_thm thy "IsaPHOLUtils.IsaP_eq_commute"
  
  fun mk_const_infos_ac all_funs datatypes thrms thy = 
    let 
    val ctab = IsaCoSy_SynthFundefs.init_const_infos_for_just 
               all_funs datatypes thrms thy 
    in 
      List.foldl check_ac (ctab, thy) fun_consts 
    end;
  
  (* Call IsaCoSy with the given parameters *)
  fun run_isacosy params thy =
    let 
    val tydata = MFunDef.ThyData.get thy
    val all_funs = map (Fn.NTab.get (get_fntab tydata)) 
                       (Fn.NSet.list_of 
                           (get_funs params))
    val datatypes = map (Tn.NTab.get types_tab) 
                        (get_dataypes params)
    val constInfoTab = mk_const_infos_ac
                       all_funs datatypes 
                       (get_thrms params) thy
    val ((cinfo, thy'), (conjs, thrms)) =
    Synthesis.synthesise_eq_terms (get_minsize params, get_maxsize params) 
                                   (get_maxvars params) thy 
                                   constInfoTab
    in
      add_thrms (conjs, thrms) thy'
    end;
  
  end; (* end local *)
end; (* End struct *)
*}

end