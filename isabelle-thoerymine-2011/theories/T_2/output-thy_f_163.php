<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>2</sub> = C<sub>d</sub>(T<sub>2</sub>, Bool) |  C<sub>c</sub>(&#8469;, &#8469;)
  <br>
   
  T<sub>7</sub> = C<sub>n</sub>(T<sub>7</sub>) |  C<sub>m</sub>(&#8469;, &#8469;)
<br>
<br>
f<sub>&epsilon;&chi;</sub> : T<sub>2</sub> &times;  T<sub>7</sub> &#8594; T<sub>2</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&epsilon;&chi;</sub>(C<sub>c</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>c</sub>(b, a)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&epsilon;&chi;</sub>(C<sub>d</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  f<sub>&epsilon;&chi;</sub>(a, c)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&epsilon;&chi;</sub>(f<sub>&epsilon;&chi;</sub>(f<sub>&epsilon;&chi;</sub>(a, b), b), b) = f<sub>&epsilon;&chi;</sub>(a, b)'));

?>