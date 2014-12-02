theory "ml_serialisation"
imports "../TM_Data"
begin

ML {*
signature ML_SERIALISATION = 
sig
  (* ML Seriarisation support *)
  val datatype_to_ml : Proof.context -> Tn.name -> string
  val function_to_ml : Proof.context -> Fn.name -> string
  
  val ml_to_datatype : Proof.context -> string -> NamedDType.T
  val ml_to_function : Proof.context -> string -> (string * typ) * term list
end

structure ML_Serialisation = 
struct

  fun datatype_to_ml ctxt ty_name = 
    ty_name |> TM_Data.DType.Ctxt.get_dtyp ctxt
            |> NamedDType.ml_pretty
            |> Pretty.string_of
  
  fun function_to_ml ctxt fn_name =
    fn_name |> Fn.NTab.get (TM_Data.Fun.Ctxt.get_fntab ctxt)
            |> (fn ((n,ty),eqns) =>
        [Pretty.str "(",
          Pretty.str "(", Pretty.quote (Pretty.str n), Pretty.str ", ", (Pretty.str o Trm.MLSerialise.string_of_type) ty,
          Pretty.str "), ", Pretty.str "["] @ Pretty.commas (map (Pretty.str o Trm.MLSerialise.string_of_term) eqns) @ [Pretty.str "]", Pretty.str ")"]
              |> Pretty.block
              |> Pretty.string_of)
  
  fun ml_to_datatype ctxt ml_str = 
      let val namedDType_ref = Unsynchronized.ref NONE 
        : (unit -> NamedDType.T) option Unsynchronized.ref
      in ML_Context.evaluate ctxt false   
         ("ML_Serialisation.namedDType_ref",namedDType_ref) ml_str
      end;
  
  fun ml_to_function ctxt ml_str = 
      let 
        val function_ref = Unsynchronized.ref NONE 
        : (unit -> ((string * typ) * term list)) option Unsynchronized.ref
      in
        ML_Context.evaluate ctxt false 
          ("ML_Serialisation.function_ref",function_ref) ml_str
      end;

end;

local structure CheckML_Serialisation : ML_SERIALISATION = ML_Serialisation in val _ = () end;
*}

ML {*
  (Tn.mk "T_1") 
    |> ML_Serialisation.datatype_to_ml @{context}
    |> ML_Serialisation.ml_to_datatype @{context}
*}

ML {*
  (Fn.mk "f_1") 
    |> ML_Serialisation.function_to_ml @{context}
    |> ML_Serialisation.ml_to_function @{context}
*}

ML {*
  ML_Serialisation.datatype_to_ml @{context} (Tn.mk "T_1");
  ML_Serialisation.function_to_ml @{context} (Fn.mk "f_1");
*}


end;
