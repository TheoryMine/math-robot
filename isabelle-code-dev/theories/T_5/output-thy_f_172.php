<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>5</sub> = C<sub>j</sub>(T<sub>5</sub>, &#8469;) |  C<sub>i</sub>(Bool, Bool)
  <br>
   
  T<sub>11</sub> = C<sub>t</sub>(Bool) |  C<sub>s</sub>(T<sub>11</sub>, &#8469;)
<br>
<br>
f<sub>&zeta;&delta;</sub> : T<sub>5</sub> &times;  T<sub>11</sub> &#8594; T<sub>5</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&zeta;&delta;</sub>(C<sub>i</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>i</sub>(a, a)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&zeta;&delta;</sub>(C<sub>j</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>j</sub>(f<sub>&zeta;&delta;</sub>(a, c), b)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&zeta;&delta;</sub>(f<sub>&zeta;&delta;</sub>(f<sub>&zeta;&delta;</sub>(a, b), c), b) = f<sub>&zeta;&delta;</sub>(a, c)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&zeta;&delta;</sub>(f<sub>&zeta;&delta;</sub>(a, b), b) = f<sub>&zeta;&delta;</sub>(a, b)'));

?>