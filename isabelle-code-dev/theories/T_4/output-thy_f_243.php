<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>4</sub> = C<sub>h</sub>(T<sub>4</sub>, Bool) |  C<sub>g</sub>(Bool, &#8469;)
  <br>
   
  T<sub>12</sub> = C<sub>v</sub>(T<sub>12</sub>) |  C<sub>u</sub>(Bool, Bool)
<br>
<br>
f<sub>&theta&sigma;</sub> : T<sub>4</sub> &times;  T<sub>12</sub> &#8594; T<sub>4</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&theta&sigma;</sub>(C<sub>g</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>h</sub>(C<sub>g</sub>(a, b), a)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&theta&sigma;</sub>(C<sub>h</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  f<sub>&theta&sigma;</sub>(a, c)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&theta&sigma;</sub>(f<sub>&theta&sigma;</sub>(f<sub>&theta&sigma;</sub>(a, b), c), b) = f<sub>&theta&sigma;</sub>(a, c)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&theta&sigma;</sub>(f<sub>&theta&sigma;</sub>(a, b), b) = f<sub>&theta&sigma;</sub>(a, b)'));

?>