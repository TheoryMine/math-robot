theory TestThyPrint
imports tm_functions
uses "../PrintToThy.ML"

 "../php_synth_output.ML"

begin
ML{* 
open PrettySynthOutput;
*}
ML{*
use "../PrettySynthOutput.ML";
*}
-- "Material world datatype is Tn"
ML {* 
open PrintToThy;
PrintToThy.print_tm_dtyp_to_thy @{context} (Tn.mk "T_1"); *}


end