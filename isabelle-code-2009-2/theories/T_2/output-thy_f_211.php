<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>2</sub> = C<sub>d</sub>(T<sub>2</sub>, Bool) |  C<sub>c</sub>(&#8469;, &#8469;)
  <br>
   
  T<sub>11</sub> = C<sub>t</sub>(Bool) |  C<sub>s</sub>(T<sub>11</sub>, &#8469;)
<br>
<br>
f<sub>&eta;&omicron;</sub> : T<sub>2</sub> &times;  T<sub>11</sub> &#8594; T<sub>2</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&eta;&omicron;</sub>(C<sub>c</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>c</sub>(a, b)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&eta;&omicron;</sub>(C<sub>d</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  f<sub>&eta;&omicron;</sub>(a, c)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&eta;&omicron;</sub>(f<sub>&eta;&omicron;</sub>(f<sub>&eta;&omicron;</sub>(a, b), c), b) = f<sub>&eta;&omicron;</sub>(a, c)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&eta;&omicron;</sub>(f<sub>&eta;&omicron;</sub>(a, b), b) = f<sub>&eta;&omicron;</sub>(a, b)'));

?>