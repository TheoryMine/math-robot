<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>5</sub> = C<sub>j</sub>(T<sub>5</sub>, &#8469;) |  C<sub>i</sub>(Bool, Bool)
  <br>
   
  T<sub>8</sub> = C<sub>p</sub>(T<sub>8</sub>) |  C<sub>o</sub>(Bool, &#8469;)
<br>
<br>
f<sub>&epsilon;&alpha;</sub> : T<sub>5</sub> &times;  T<sub>8</sub> &#8594; T<sub>5</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&epsilon;&alpha;</sub>(C<sub>i</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>i</sub>(a, b)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&epsilon;&alpha;</sub>(C<sub>j</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>j</sub>(f<sub>&epsilon;&alpha;</sub>(a, c), b)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&epsilon;&alpha;</sub>(f<sub>&epsilon;&alpha;</sub>(f<sub>&epsilon;&alpha;</sub>(a, b), c), b) = a'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&epsilon;&alpha;</sub>(f<sub>&epsilon;&alpha;</sub>(a, b), b) = a'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&epsilon;&alpha;</sub>(a, b) = a'));

?>