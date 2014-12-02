<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>2</sub> = C<sub>d</sub>(T<sub>2</sub>, Bool) |  C<sub>c</sub>(&#8469;, &#8469;)
  <br>
   
  T<sub>13</sub> = C<sub>x</sub>(&#8469;) |  C<sub>w</sub>(T<sub>13</sub>, Bool)
<br>
<br>
f<sub>&theta&omega;</sub> : T<sub>2</sub> &times;  T<sub>13</sub> &#8594; T<sub>2</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&theta&omega;</sub>(C<sub>c</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>c</sub>(b, a)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&theta&omega;</sub>(C<sub>d</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>d</sub>(f<sub>&theta&omega;</sub>(a, c), b)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&theta&omega;</sub>(f<sub>&theta&omega;</sub>(f<sub>&theta&omega;</sub>(a, b), c), b) = f<sub>&theta&omega;</sub>(a, c)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&theta&omega;</sub>(f<sub>&theta&omega;</sub>(f<sub>&theta&omega;</sub>(f<sub>&theta&omega;</sub>(a, b), c), b), c) = a'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&theta&omega;</sub>(f<sub>&theta&omega;</sub>(a, b), b) = a'));

?>