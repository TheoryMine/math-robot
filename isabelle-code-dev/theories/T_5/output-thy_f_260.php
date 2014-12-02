<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>5</sub> = C<sub>j</sub>(T<sub>5</sub>, &#8469;) |  C<sub>i</sub>(Bool, Bool)
  <br>
   
  T<sub>16</sub> = C<sub>ad</sub>(T<sub>16</sub>) |  C<sub>ac</sub>(Bool)
<br>
<br>
f<sub>&iota;&theta</sub> : T<sub>5</sub> &times;  T<sub>16</sub> &#8594; T<sub>5</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&iota;&theta</sub>(C<sub>i</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>i</sub>(a, b)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&iota;&theta</sub>(C<sub>j</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>j</sub>(f<sub>&iota;&theta</sub>(a, c), b)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&iota;&theta</sub>(f<sub>&iota;&theta</sub>(f<sub>&iota;&theta</sub>(a, b), c), b) = a'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&iota;&theta</sub>(f<sub>&iota;&theta</sub>(a, b), b) = a'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&iota;&theta</sub>(a, b) = a'));

?>