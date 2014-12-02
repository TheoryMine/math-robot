<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>3</sub> = C<sub>f</sub>(T<sub>3</sub>, &#8469;) |  C<sub>e</sub>(Bool, &#8469;)
  <br>
   
  T<sub>8</sub> = C<sub>p</sub>(T<sub>8</sub>) |  C<sub>o</sub>(Bool, &#8469;)
<br>
<br>
f<sub>&eta;&chi;</sub> : T<sub>3</sub> &times;  T<sub>8</sub> &#8594; T<sub>8</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&eta;&chi;</sub>(C<sub>e</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  c
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&eta;&chi;</sub>(C<sub>f</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  f<sub>&eta;&chi;</sub>(a, c)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&eta;&chi;</sub>(a, b) = b'));

?>