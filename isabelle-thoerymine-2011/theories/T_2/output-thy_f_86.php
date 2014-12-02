<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>2</sub> = C<sub>d</sub>(T<sub>2</sub>, Bool) |  C<sub>c</sub>(&#8469;, &#8469;)
<br>
<br>
f<sub>&gamma;&beta;</sub> : T<sub>2</sub> &times;  T<sub>2</sub> &#8594; T<sub>2</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&gamma;&beta;</sub>(C<sub>c</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>c</sub>(b, b)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&gamma;&beta;</sub>(C<sub>d</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>d</sub>(C<sub>d</sub>(f<sub>&gamma;&beta;</sub>(a, c), b), b)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&gamma;&beta;</sub>(a, f<sub>&gamma;&beta;</sub>(b, f<sub>&gamma;&beta;</sub>(a, b))) = f<sub>&gamma;&beta;</sub>(a, b)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&gamma;&beta;</sub>(a, f<sub>&gamma;&beta;</sub>(f<sub>&gamma;&beta;</sub>(a, a), b)) = f<sub>&gamma;&beta;</sub>(a, b)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&gamma;&beta;</sub>(a, f<sub>&gamma;&beta;</sub>(a, b)) = f<sub>&gamma;&beta;</sub>(a, b)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&gamma;&beta;</sub>(a, C<sub>d</sub>(b, c)) = f<sub>&gamma;&beta;</sub>(a, b)'));

?>