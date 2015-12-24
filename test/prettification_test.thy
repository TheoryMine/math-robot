header{* Isabelle code to synthesise function definitions in ML *}
theory prettification_test
imports TM_Data
begin

ML{*
*}

(* (Pretty.string_of (Trm.pretty @{context} @{term "f_1(C_4(x :: T_2)) = C_97"})); *)
ML {*
  val html_str = StringReformater.stringterm_to_html false 
        "f_40: T_1 &times; T_10 &#8594; T_1";

(*StringReformater.fname_to_FO_spec_string;  
val fo_str = term_to_FO_string @{term "f_1(C_4(x :: T_2)) = C_97"};
val dt_str = datatype_to_FO_string @{context} "T_2"*)
*}

end;
