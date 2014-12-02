<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>3</sub> = C<sub>f</sub>(T<sub>3</sub>, &#8469;) |  C<sub>e</sub>(Bool, &#8469;)
  <br>
   
  T<sub>11</sub> = C<sub>t</sub>(Bool) |  C<sub>s</sub>(T<sub>11</sub>, &#8469;)
<br>
<br>
f<sub>&theta&tau;</sub> : T<sub>3</sub> &times;  T<sub>11</sub> &#8594; T<sub>3</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&theta&tau;</sub>(C<sub>e</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>f</sub>(C<sub>f</sub>(C<sub>e</sub>(a, b), b), b)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&theta&tau;</sub>(C<sub>f</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  f<sub>&theta&tau;</sub>(a, c)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&theta&tau;</sub>(f<sub>&theta&tau;</sub>(f<sub>&theta&tau;</sub>(a, b), c), b) = f<sub>&theta&tau;</sub>(a, c)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&theta&tau;</sub>(f<sub>&theta&tau;</sub>(a, b), b) = f<sub>&theta&tau;</sub>(a, b)'));

?>