signature ML_SERIALISATION = 
sig
  (* ML Seriarisation support *)
  val term_to_ml : term -> string

  val datatype_to_ml : NamedDType.T -> string
  val lookup_dn_to_ml : Proof.context -> Tn.name -> string

  val function_to_ml : ((string * typ) * term list) -> string
  val lookup_fn_to_ml : Proof.context -> Fn.name -> string
  
  val ml_to_term : Proof.context -> string -> term
  val ml_to_datatype : Proof.context -> string -> NamedDType.T
  val ml_to_function : Proof.context -> string -> (string * typ) * term list

  (* internal *)  
  val term_ref : (unit -> term) option Unsynchronized.ref
  val namedDType_ref : (unit -> NamedDType.T) option Unsynchronized.ref
  val function_ref : (unit -> ((string * typ) * term list)) option Unsynchronized.ref
end

structure ML_Serialisation = 
struct

  fun term_to_ml t = Trm.MLSerialise.string_of_term t;

  fun datatype_to_ml d = 
      Pretty.string_of (NamedDType.ml_pretty d);

  fun lookup_dn_to_ml ctxt ty_name = 
      datatype_to_ml (TM_Data.DType.Ctxt.get_dtyp ctxt ty_name);

  fun function_to_ml ((n,ty),eqns) =
      (Pretty.string_of o Pretty.block)
        ([ Pretty.str "(",
           Pretty.str "(", Pretty.quote (Pretty.str n), Pretty.str ", ", 
           (Pretty.str o  Trm.MLSerialise.string_of_type) ty,
           Pretty.str "), ", Pretty.str "["] 
         @ Pretty.commas (map (Pretty.str o Trm.MLSerialise.string_of_term) eqns)
         @ [Pretty.str "]", Pretty.str ")"]);

  fun lookup_fn_to_ml ctxt fn_name =
      function_to_ml (Fn.NTab.get (TM_Data.Fun.Ctxt.get_fntab ctxt) fn_name);  

  (* internal values needed by Isabelle's evaluator, referenced from within a string *)
  val namedDType_ref = Unsynchronized.ref NONE 
        : (unit -> NamedDType.T) option Unsynchronized.ref;
  val function_ref = Unsynchronized.ref NONE 
        : (unit -> ((string * typ) * term list)) option Unsynchronized.ref;
  val term_ref = Unsynchronized.ref NONE 
        : (unit -> term) option Unsynchronized.ref;

  (* parse/evaluate an isabelle string into a value of the right type *)
  fun ml_to_datatype ctxt ml_str = 
      ML_Context.evaluate ctxt false   
        ("ML_Serialisation.namedDType_ref",namedDType_ref) ml_str;

  fun ml_to_function ctxt ml_str = 
      ML_Context.evaluate ctxt false 
        ("ML_Serialisation.function_ref",function_ref) ml_str;

  fun ml_to_term ctxt ml_str = 
      ML_Context.evaluate ctxt false 
        ("ML_Serialisation.term_ref",term_ref) ml_str;
end;

local structure CheckML_Serialisation : ML_SERIALISATION = ML_Serialisation in val _ = () end;
