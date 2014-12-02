<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>2</sub> = C<sub>d</sub>(T<sub>2</sub>, Bool) |  C<sub>c</sub>(&#8469;, &#8469;)
  <br>
   
  T<sub>3</sub> = C<sub>f</sub>(T<sub>3</sub>, &#8469;) |  C<sub>e</sub>(Bool, &#8469;)
<br>
<br>
f<sub>&gamma;&lambda;</sub> : T<sub>2</sub> &times;  T<sub>3</sub> &#8594; T<sub>2</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&gamma;&lambda;</sub>(C<sub>c</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>c</sub>(b, a)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&gamma;&lambda;</sub>(C<sub>d</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  f<sub>&gamma;&lambda;</sub>(a, c)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&gamma;&lambda;</sub>(f<sub>&gamma;&lambda;</sub>(f<sub>&gamma;&lambda;</sub>(a, b), b), b) = f<sub>&gamma;&lambda;</sub>(a, b)'));

?>