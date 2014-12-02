<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>2</sub> = C<sub>d</sub>(T<sub>2</sub>, Bool) |  C<sub>c</sub>(&#8469;, &#8469;)
  <br>
   
  T<sub>11</sub> = C<sub>t</sub>(Bool) |  C<sub>s</sub>(T<sub>11</sub>, &#8469;)
<br>
<br>
f<sub>&eta;&psi;</sub> : T<sub>2</sub> &times;  T<sub>11</sub> &#8594; T<sub>11</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&eta;&psi;</sub>(C<sub>c</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  c
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&eta;&psi;</sub>(C<sub>d</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  f<sub>&eta;&psi;</sub>(a, c)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&eta;&psi;</sub>(a, b) = b'));

?>