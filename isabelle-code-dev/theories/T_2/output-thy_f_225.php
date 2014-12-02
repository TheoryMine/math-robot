<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>2</sub> = C<sub>d</sub>(T<sub>2</sub>, Bool) |  C<sub>c</sub>(&#8469;, &#8469;)
  <br>
   
  T<sub>12</sub> = C<sub>v</sub>(T<sub>12</sub>) |  C<sub>u</sub>(Bool, Bool)
<br>
<br>
f<sub>&theta&alpha;</sub> : T<sub>2</sub> &times;  T<sub>12</sub> &#8594; T<sub>2</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&theta&alpha;</sub>(C<sub>c</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>c</sub>(a, a)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&theta&alpha;</sub>(C<sub>d</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  f<sub>&theta&alpha;</sub>(a, c)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&theta&alpha;</sub>(f<sub>&theta&alpha;</sub>(f<sub>&theta&alpha;</sub>(a, b), c), b) = f<sub>&theta&alpha;</sub>(a, c)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&theta&alpha;</sub>(f<sub>&theta&alpha;</sub>(a, b), b) = f<sub>&theta&alpha;</sub>(a, b)'));

?>