<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>5</sub> = C<sub>j</sub>(T<sub>5</sub>, &#8469;) |  C<sub>i</sub>(Bool, Bool)
  <br>
   
  T<sub>14</sub> = C<sub>z</sub>(Bool) |  C<sub>y</sub>(T<sub>14</sub>, Bool)
<br>
<br>
f<sub>&theta&alpha;</sub> : T<sub>5</sub> &times;  T<sub>14</sub> &#8594; T<sub>5</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&theta&alpha;</sub>(C<sub>i</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>i</sub>(a, b)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&theta&alpha;</sub>(C<sub>j</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  f<sub>&theta&alpha;</sub>(a, c)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&theta&alpha;</sub>(f<sub>&theta&alpha;</sub>(f<sub>&theta&alpha;</sub>(a, b), c), b) = f<sub>&theta&alpha;</sub>(a, c)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&theta&alpha;</sub>(f<sub>&theta&alpha;</sub>(a, b), b) = f<sub>&theta&alpha;</sub>(a, b)'));

?>