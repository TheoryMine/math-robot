<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>2</sub> = C<sub>d</sub>(T<sub>2</sub>, Bool) |  C<sub>c</sub>(&#8469;, &#8469;)
  <br>
   
  T<sub>4</sub> = C<sub>h</sub>(T<sub>4</sub>, Bool) |  C<sub>g</sub>(Bool, &#8469;)
<br>
<br>
f<sub>&delta;&zeta;</sub> : T<sub>2</sub> &times;  T<sub>4</sub> &#8594; T<sub>4</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&delta;&zeta;</sub>(C<sub>c</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  c
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&delta;&zeta;</sub>(C<sub>d</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  f<sub>&delta;&zeta;</sub>(a, c)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&delta;&zeta;</sub>(a, b) = b'));

?>