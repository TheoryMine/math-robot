<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>2</sub> = C<sub>d</sub>(T<sub>2</sub>, Bool) |  C<sub>c</sub>(&#8469;, &#8469;)
  <br>
   
  T<sub>15</sub> = C<sub>ab</sub>(T<sub>15</sub>) |  C<sub>aa</sub>(&#8469;)
<br>
<br>
f<sub>&kappa;&zeta;</sub> : T<sub>2</sub> &times;  T<sub>15</sub> &#8594; T<sub>2</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&kappa;&zeta;</sub>(C<sub>c</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>c</sub>(b, b)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&kappa;&zeta;</sub>(C<sub>d</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>d</sub>(f<sub>&kappa;&zeta;</sub>(a, c), b)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&kappa;&zeta;</sub>(f<sub>&kappa;&zeta;</sub>(f<sub>&kappa;&zeta;</sub>(a, b), c), b) = f<sub>&kappa;&zeta;</sub>(a, c)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&kappa;&zeta;</sub>(f<sub>&kappa;&zeta;</sub>(a, b), b) = f<sub>&kappa;&zeta;</sub>(a, b)'));

?>