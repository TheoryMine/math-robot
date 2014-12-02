<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>5</sub> = C<sub>j</sub>(T<sub>5</sub>, &#8469;) |  C<sub>i</sub>(Bool, Bool)
<br>
<br>
f<sub>&gamma;&pi;</sub> : T<sub>5</sub> &times;  T<sub>5</sub> &#8594; T<sub>5</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&gamma;&pi;</sub>(C<sub>i</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>i</sub>(b, b)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&gamma;&pi;</sub>(C<sub>j</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>j</sub>(C<sub>j</sub>(f<sub>&gamma;&pi;</sub>(a, c), b), b)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&gamma;&pi;</sub>(a, f<sub>&gamma;&pi;</sub>(b, f<sub>&gamma;&pi;</sub>(b, a))) = f<sub>&gamma;&pi;</sub>(a, b)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&gamma;&pi;</sub>(a, f<sub>&gamma;&pi;</sub>(f<sub>&gamma;&pi;</sub>(b, b), b)) = f<sub>&gamma;&pi;</sub>(a, a)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&gamma;&pi;</sub>(a, f<sub>&gamma;&pi;</sub>(b, b)) = f<sub>&gamma;&pi;</sub>(a, b)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&gamma;&pi;</sub>(a, C<sub>j</sub>(b, c)) = f<sub>&gamma;&pi;</sub>(a, b)'));

?>