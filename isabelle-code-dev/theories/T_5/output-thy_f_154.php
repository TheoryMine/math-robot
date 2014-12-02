<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>5</sub> = C<sub>j</sub>(T<sub>5</sub>, &#8469;) |  C<sub>i</sub>(Bool, Bool)
  <br>
   
  T<sub>9</sub> = C<sub>r</sub>(&#8469;) |  C<sub>q</sub>(T<sub>9</sub>, &#8469;)
<br>
<br>
f<sub>&epsilon;&xi;</sub> : T<sub>5</sub> &times;  T<sub>9</sub> &#8594; T<sub>5</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&epsilon;&xi;</sub>(C<sub>i</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>i</sub>(a, a)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&epsilon;&xi;</sub>(C<sub>j</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  f<sub>&epsilon;&xi;</sub>(a, c)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&epsilon;&xi;</sub>(f<sub>&epsilon;&xi;</sub>(f<sub>&epsilon;&xi;</sub>(a, b), c), b) = f<sub>&epsilon;&xi;</sub>(a, c)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&epsilon;&xi;</sub>(f<sub>&epsilon;&xi;</sub>(a, b), b) = f<sub>&epsilon;&xi;</sub>(a, b)'));

?>