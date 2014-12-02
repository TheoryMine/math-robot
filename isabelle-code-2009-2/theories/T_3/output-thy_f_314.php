<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>3</sub> = C<sub>f</sub>(T<sub>3</sub>, &#8469;) |  C<sub>e</sub>(Bool, &#8469;)
  <br>
   
  T<sub>16</sub> = C<sub>ad</sub>(T<sub>16</sub>) |  C<sub>ac</sub>(Bool)
<br>
<br>
f<sub>&lambda;&zeta;</sub> : T<sub>3</sub> &times;  T<sub>16</sub> &#8594; T<sub>3</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&lambda;&zeta;</sub>(C<sub>e</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>f</sub>(C<sub>f</sub>(C<sub>e</sub>(a, b), b), b)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&lambda;&zeta;</sub>(C<sub>f</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  f<sub>&lambda;&zeta;</sub>(a, c)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&lambda;&zeta;</sub>(f<sub>&lambda;&zeta;</sub>(f<sub>&lambda;&zeta;</sub>(a, b), c), b) = f<sub>&lambda;&zeta;</sub>(a, c)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&lambda;&zeta;</sub>(f<sub>&lambda;&zeta;</sub>(a, b), b) = f<sub>&lambda;&zeta;</sub>(a, b)'));

?>