<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>2</sub> = C<sub>d</sub>(T<sub>2</sub>, Bool) |  C<sub>c</sub>(&#8469;, &#8469;)
  <br>
   
  T<sub>7</sub> = C<sub>n</sub>(T<sub>7</sub>) |  C<sub>m</sub>(&#8469;, &#8469;)
<br>
<br>
f<sub>&epsilon;&sigmaf;</sub> : T<sub>2</sub> &times;  T<sub>7</sub> &#8594; T<sub>2</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&epsilon;&sigmaf;</sub>(C<sub>c</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>c</sub>(a, a)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&epsilon;&sigmaf;</sub>(C<sub>d</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>d</sub>(f<sub>&epsilon;&sigmaf;</sub>(a, c), b)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&epsilon;&sigmaf;</sub>(f<sub>&epsilon;&sigmaf;</sub>(f<sub>&epsilon;&sigmaf;</sub>(a, b), c), b) = f<sub>&epsilon;&sigmaf;</sub>(a, c)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&epsilon;&sigmaf;</sub>(f<sub>&epsilon;&sigmaf;</sub>(a, b), b) = f<sub>&epsilon;&sigmaf;</sub>(a, b)'));

?>