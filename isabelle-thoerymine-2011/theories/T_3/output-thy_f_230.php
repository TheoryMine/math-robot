<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>3</sub> = C<sub>f</sub>(T<sub>3</sub>, &#8469;) |  C<sub>e</sub>(Bool, &#8469;)
  <br>
   
  T<sub>9</sub> = C<sub>r</sub>(&#8469;) |  C<sub>q</sub>(T<sub>9</sub>, &#8469;)
<br>
<br>
f<sub>&theta&zeta;</sub> : T<sub>3</sub> &times;  T<sub>9</sub> &#8594; T<sub>3</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&theta&zeta;</sub>(C<sub>e</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>f</sub>(C<sub>f</sub>(C<sub>e</sub>(a, b), b), b)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&theta&zeta;</sub>(C<sub>f</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  f<sub>&theta&zeta;</sub>(a, c)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&theta&zeta;</sub>(f<sub>&theta&zeta;</sub>(f<sub>&theta&zeta;</sub>(a, b), c), b) = f<sub>&theta&zeta;</sub>(a, c)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&theta&zeta;</sub>(f<sub>&theta&zeta;</sub>(a, b), b) = f<sub>&theta&zeta;</sub>(a, b)'));

?>