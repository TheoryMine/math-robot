<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>2</sub> = C<sub>d</sub>(T<sub>2</sub>, Bool) |  C<sub>c</sub>(&#8469;, &#8469;)
  <br>
   
  T<sub>6</sub> = C<sub>l</sub>(T<sub>6</sub>, Bool) |  C<sub>k</sub>(Bool, Bool)
<br>
<br>
f<sub>&epsilon;&alpha;</sub> : T<sub>2</sub> &times;  T<sub>6</sub> &#8594; T<sub>2</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&epsilon;&alpha;</sub>(C<sub>c</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>c</sub>(a, a)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&epsilon;&alpha;</sub>(C<sub>d</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>d</sub>(f<sub>&epsilon;&alpha;</sub>(a, c), b)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&epsilon;&alpha;</sub>(f<sub>&epsilon;&alpha;</sub>(f<sub>&epsilon;&alpha;</sub>(a, b), c), b) = f<sub>&epsilon;&alpha;</sub>(a, c)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&epsilon;&alpha;</sub>(f<sub>&epsilon;&alpha;</sub>(a, b), b) = f<sub>&epsilon;&alpha;</sub>(a, b)'));

?>