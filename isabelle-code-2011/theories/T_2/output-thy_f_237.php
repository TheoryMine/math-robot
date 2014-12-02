<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>2</sub> = C<sub>d</sub>(T<sub>2</sub>, Bool) |  C<sub>c</sub>(&#8469;, &#8469;)
  <br>
   
  T<sub>12</sub> = C<sub>v</sub>(T<sub>12</sub>) |  C<sub>u</sub>(Bool, Bool)
<br>
<br>
f<sub>&theta&nu;</sub> : T<sub>2</sub> &times;  T<sub>12</sub> &#8594; T<sub>12</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&theta&nu;</sub>(C<sub>c</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  c
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&theta&nu;</sub>(C<sub>d</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  f<sub>&theta&nu;</sub>(a, c)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&theta&nu;</sub>(a, b) = b'));

?>