<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>3</sub> = C<sub>f</sub>(T<sub>3</sub>, &#8469;) |  C<sub>e</sub>(Bool, &#8469;)
  <br>
   
  T<sub>14</sub> = C<sub>z</sub>(Bool) |  C<sub>y</sub>(T<sub>14</sub>, Bool)
<br>
<br>
f<sub>&kappa;&zeta;</sub> : T<sub>3</sub> &times;  T<sub>14</sub> &#8594; T<sub>3</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&kappa;&zeta;</sub>(C<sub>e</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>f</sub>(C<sub>f</sub>(C<sub>e</sub>(a, b), b), b)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&kappa;&zeta;</sub>(C<sub>f</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  f<sub>&kappa;&zeta;</sub>(a, c)
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