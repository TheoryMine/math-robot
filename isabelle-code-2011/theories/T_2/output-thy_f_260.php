<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>2</sub> = C<sub>d</sub>(T<sub>2</sub>, Bool) |  C<sub>c</sub>(&#8469;, &#8469;)
  <br>
   
  T<sub>14</sub> = C<sub>z</sub>(Bool) |  C<sub>y</sub>(T<sub>14</sub>, Bool)
<br>
<br>
f<sub>&iota;&theta</sub> : T<sub>2</sub> &times;  T<sub>14</sub> &#8594; T<sub>2</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&iota;&theta</sub>(C<sub>c</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>c</sub>(a, a)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&iota;&theta</sub>(C<sub>d</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>d</sub>(f<sub>&iota;&theta</sub>(a, c), b)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&iota;&theta</sub>(f<sub>&iota;&theta</sub>(f<sub>&iota;&theta</sub>(a, b), c), b) = f<sub>&iota;&theta</sub>(a, c)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&iota;&theta</sub>(f<sub>&iota;&theta</sub>(a, b), b) = f<sub>&iota;&theta</sub>(a, b)'));

?>