<?

/* the string version of the theory; generated from datatypes AND function defs using prettification. Prettificsation with "true" flag to get it into a table. */
$theory = 
'<table> <tr><td align="center">   T<sub>1</sub> = C<sub>a</sub>(T<sub>1</sub>, &#8469;) | C<sub>b</sub>(&#8469;, &#8469;)   <br>   T<sub>2</sub> = C<sub>c</sub>(T<sub>2</sub>, Bool) | C<sub>d</sub>(&#8469;, &#8469;)   <br><br>   f<sub>&#978;</sub> : T<sub>1</sub> &times; T<sub>2</sub> &#8594; T<sub>1</sub>   </td></tr></table> <table>   <tr><td width="48%" align="right">f<sub>&#978;</sub>(C<sub>a</sub> (x, y), z) </td><td width="4%" align="center">=</td><td width="48%" align="left"> C<sub>b</sub>(C<sub>b</sub>(C<sub>a</sub>(y, x), y), x)</td></tr>    <tr><td width="48%" align="right">f<sub>&#978;</sub>(C<sub>b</sub>(x, y), z) </td><td width="4%" align="center">=</td><td width="48%" align="left"> C<sub>b</sub> (f<sub>&#978;</sub>(x, z), y)</td></tr> </table>';

$theorems = array();

/* constructed for each theorem in the theory; using prettification with the "false" flag to not put it into a table. */
array_push($theorems, 
  array("proof" => "induction and rippling", 
        "statement" => "f<sub>&upsih;</sub>(f<sub>&upsih;</sub>(x, y), z) = f<sub>&upsih;</sub>(f<sub>&upsih;</sub>(x, y), y)"));

array_push($theorems, 
  array("proof" => "induction and rippling", 
        "statement" => "f<sub>&upsih;</sub>(f<sub>&upsih;</sub>(x, y), z) = f<sub>&upsih;</sub>(f<sub>&upsih;</sub>(x, z), y)"));

array_push($theorems, 
  array("proof" => "induction and rippling", 
        "statement" => "f<sub>&upsih;</sub>(f<sub>&upsih;</sub>(x, y), z) = f<sub>&upsih;</sub>(f<sub>&upsih;</sub>(x, z), z)"));

?>
