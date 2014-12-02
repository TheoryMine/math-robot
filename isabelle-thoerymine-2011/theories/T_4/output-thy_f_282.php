<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>4</sub> = C<sub>h</sub>(T<sub>4</sub>, Bool) |  C<sub>g</sub>(Bool, &#8469;)
  <br>
   
  T<sub>15</sub> = C<sub>ab</sub>(T<sub>15</sub>) |  C<sub>aa</sub>(&#8469;)
<br>
<br>
f<sub>&kappa;&beta;</sub> : T<sub>4</sub> &times;  T<sub>15</sub> &#8594; T<sub>4</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&kappa;&beta;</sub>(C<sub>g</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>g</sub>(a, b)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&kappa;&beta;</sub>(C<sub>h</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  f<sub>&kappa;&beta;</sub>(a, c)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&kappa;&beta;</sub>(f<sub>&kappa;&beta;</sub>(f<sub>&kappa;&beta;</sub>(a, b), c), b) = f<sub>&kappa;&beta;</sub>(a, c)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&kappa;&beta;</sub>(f<sub>&kappa;&beta;</sub>(a, b), b) = f<sub>&kappa;&beta;</sub>(a, b)'));

?>