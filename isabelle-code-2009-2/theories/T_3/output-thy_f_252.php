<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>3</sub> = C<sub>f</sub>(T<sub>3</sub>, &#8469;) |  C<sub>e</sub>(Bool, &#8469;)
  <br>
   
  T<sub>12</sub> = C<sub>v</sub>(T<sub>12</sub>) |  C<sub>u</sub>(Bool, Bool)
<br>
<br>
f<sub>&theta&piv;</sub> : T<sub>3</sub> &times;  T<sub>12</sub> &#8594; T<sub>3</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&theta&piv;</sub>(C<sub>e</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>e</sub>(a, b)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&theta&piv;</sub>(C<sub>f</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  f<sub>&theta&piv;</sub>(a, c)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&theta&piv;</sub>(f<sub>&theta&piv;</sub>(f<sub>&theta&piv;</sub>(a, b), c), b) = f<sub>&theta&piv;</sub>(a, c)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&theta&piv;</sub>(f<sub>&theta&piv;</sub>(a, b), b) = f<sub>&theta&piv;</sub>(a, b)'));

?>