(* 
  String reformatting finds things like f_2 and changes it to f_{\beta}
*)
functor BaseNameChangeFun(
  type char (* notion of character for the new base *)
  val compare : char -> char -> order
  val alphabet : char list (* new base to change characters to *)
) =
struct

val bot_char = hd alphabet;
val top_char = List.last alphabet;

val char_root = 0;
val int_base = length alphabet; (* cannot be 0 *)

(* integers as chrlist, working in the above base with the given root 
   e.g. "a" = 0, "b" = 1, "ab" = int_base + 1, "aab" = int_base ^ 2 + 1, etc
*)
fun chrlist_of_int i = 
    let 
      fun chrlist_of' 0 l = l
        | chrlist_of' i l = 
          let val (q,r) = IntInf.quotRem (i, int_base) (* Maybe use Integer.div_mod ? what's the difference? *)
          in if r = 0 then 
               chrlist_of' (q - 1) (top_char::l)
             else 
               chrlist_of' q ((List.nth(alphabet,char_root + r -1)) :: l)
          end
    in chrlist_of' i [] end;

fun index_in_alphabet h alph=  (Library.find_index (fn a => compare h a = EQUAL) alph) + 1;

(* assumes characters between a and z. *)
(* IMPROVE? should check that c is in the int_base range? *)
fun int_of_chrlist [] = 0
  | int_of_chrlist (h::l) = 
    let
      val i0 = (index_in_alphabet h alphabet) - char_root
      fun int_of' [] a = a
        | int_of' (c::l) a = 
          let val i = (index_in_alphabet c alphabet) - char_root
          in int_of' l ((a * int_base) + i) end;
    in (int_of' l i0) end;

end;

structure GreekNChange = BaseNameChangeFun(
  type char = string 
  val compare = curry String.compare
  val alphabet = ["&alpha;",	"&beta;","&gamma;","&delta;","&epsilon;","&zeta;","&eta;","&theta;","&iota;",
  "&kappa;","&lambda;","&mu;","&nu;","&xi;","&omicron;","&pi;","&rho;","&sigmaf;","&sigma;",
  "&tau;","&upsilon;","&phi;","&chi;","&psi;","&omega;","&thetasym;","&upsih;","&piv;" ]
);


structure AlphabetNChange = BaseNameChangeFun(
  type char = string 
  val compare = curry String.compare
  val alphabet = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t",
                  "u","v","w","x","y","z"]
);

structure DigitNChange = BaseNameChangeFun(
  type char = string 
  val compare = curry String.compare
  val alphabet = ["1","2","3","4","5","6","7","8","9"]
);

structure StringReformater =
struct

exception term_bad_form;

val function_symbol = "f"; 
val function_change = GreekNChange.chrlist_of_int;
val constr_symbol = "C";
val constr_change = AlphabetNChange.chrlist_of_int;

val var_symbol = "x";

val set_symbol= "T";
val set_change = DigitNChange.chrlist_of_int;

val digits = ["1","2","3","4","5","6","7","8","9","0"]; 
fun is_digit a = List.exists (fn x => x = a) digits;


(* apperas all the digist appearing at the start of a list  in a silngle string , the lsit of the rest of the characters*)
fun take_number [] = ("",[])
  | take_number (h::t) = 
    if is_digit h then 
      (let val (n, rest) = take_number t in (h^n, rest) end)
    else ("", h::t);

fun vars_change n = 
      let
        val vars = ["x","y","z","u","v","w","i","j","k","n","m"]
        val (q,r) = IntInf.quotRem ((n-1), length vars);
        fun q_to_subname 0 = []
          | q_to_subname x = [Int.toString (q + 1)];
        val sub_opt = SOME (q_to_subname q)
      in (nth vars r, sub_opt)
      end;

fun convert_to_tuples [] = []
  | convert_to_tuples [h] = [(h, NONE)]
  | convert_to_tuples (x  ::  "_"  ::t ) = 
      let 
        val (n, char_list) = take_number t;
        val SOME n' = Int.fromString n;
      in 
        (*if (x = var_symbol) then 
          (x ^ "_", SOME (var_change n')) :: (convert_to_tuples char_list) *)
        if (x = var_symbol) then 
          (vars_change n') :: (convert_to_tuples char_list)
        else if (x = function_symbol)  then 
          (x , SOME (function_change n')) :: (convert_to_tuples char_list)
        else if (x = constr_symbol)  then 
          (x, SOME (constr_change n')) :: (convert_to_tuples char_list)
        else if (x = set_symbol)  then 
          (x, SOME (set_change n')) :: (convert_to_tuples char_list)
        else raise term_bad_form
      end
   | convert_to_tuples (h::t) = 
     (h,NONE) :: convert_to_tuples t;

fun tuples_to_string [] = ""
  | tuples_to_string ((h,NONE)::t )= h ^ (tuples_to_string t)
  | tuples_to_string ((h,SOME [])::t) =  
     h ^ (tuples_to_string t)
  | tuples_to_string ((h,SOME (x as _::_))::t) =  
     h ^ "<sub>" ^ (String.concat x) ^ "</sub>" ^ (tuples_to_string t);

(* convert a term into its database represenattion. *)
fun stringterm_to_html string = 
    let val expl_string = raw_explode string; 
        val tuple_list = convert_to_tuples expl_string;
   in tuples_to_string tuple_list end;

(* Convert a term to its first-order string representation *)
fun term_to_FO_string t = 
    let
      val (h,args) = Term.strip_comb t;
      val sargs = map term_to_FO_string args;
    in 
      if null args then 
        (case h of (Const (n,ty)) => Long_Name.base_name n
                 | (Free (n,_)) => n
                 | _ => raise ERROR "Imposible to reach an term")
      else
        (case (h,sargs) of (Const ("op =",_), [s1,s2]) => s1 ^ " = " ^ s2
         | _ => (term_to_FO_string h) ^ (if null sargs then "" else "(" ^ (commas sargs) ^ ")"))
    end;

(* Convert a datatype to its first-order string representation *)
fun datatype_to_FO_string ctxt dt_name = 
    let
      fun string_of_elem el = 
          (case el of (DataGen.Typ n) => 
             if Tn.name_eq (n,Tn.mk "B") then Pretty.str "Bool"
             else if Tn.name_eq (n,Tn.mk "N") then Pretty.str "&#8469;"
             else Tn.pretty_name n 
           | DataGen.Rec => Tn.pretty_name dt_name);
      fun string_of_elems els = 
          els |> map string_of_elem 
              |> Pretty.separate "," 
              |> (fn ps => Pretty.block ([Pretty.str "("] @ ps @ [Pretty.str ")"]));
      val NamedDType.Ndtyp ntab = TM_Data.DType.Ctxt.get_dtyp ctxt dt_name;
      val constr_cases = Fn.NTab.list_of ntab
    in
      (Pretty.string_of o Pretty.block)
        ([Tn.pretty_name dt_name, Pretty.str " = "]
        @ (Pretty.separate " | "
           (map (fn (n,el) => Pretty.block [Fn.pretty_name n, string_of_elems el]) constr_cases)))
    end;


fun pretty_of_typ ctxt typ = 
    let 
      val (arg_tys, concl_ty) = Term.strip_type typ
      fun is_compound_typ ty = case Term.strip_type ty of ([],_) => false | _ => true;
      val pretty_args = map (fn ty => if is_compound_typ ty  
                                      then Pretty.list "(" ")" [pretty_of_typ ctxt ty] 
                                      else Pretty.block [pretty_of_typ ctxt ty]) arg_tys
      val concl_pretty = (case concl_ty of Type("bool", _) => Pretty.str "Bool"
                                        | Type("nat", _) => Pretty.str "&#8469;"
                                        | _ => Trm.pretty_typ ctxt concl_ty)
    in 
      if is_compound_typ typ then 
        Pretty.block 
            ((Pretty.separate " &times; " pretty_args)
            @ [Pretty.str " &#8594; ", concl_pretty])
      else concl_pretty
    end;

val string_of_typ = Pretty.string_of oo pretty_of_typ;

fun fun_eqs_to_FO_spec_string ctxt eqns = 
    let val pretty_eqs = map (Pretty.str o term_to_FO_string o HOLogic.dest_Trueprop) eqns
    in Pretty.string_of (Pretty.chunks pretty_eqs) end;

fun fname_to_FO_spec_string ctxt fname = 
    fun_eqs_to_FO_spec_string ctxt (snd (Fn.NTab.get (TM_Data.Fun.Ctxt.get_fntab ctxt) fname));

end;
