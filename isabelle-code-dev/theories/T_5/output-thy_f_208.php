<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>5</sub> = C<sub>j</sub>(T<sub>5</sub>, &#8469;) |  C<sub>i</sub>(Bool, Bool)
  <br>
   
  T<sub>13</sub> = C<sub>x</sub>(&#8469;) |  C<sub>w</sub>(T<sub>13</sub>, Bool)
<br>
<br>
f<sub>&eta;&mu;</sub> : T<sub>5</sub> &times;  T<sub>13</sub> &#8594; T<sub>5</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&eta;&mu;</sub>(C<sub>i</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>i</sub>(a, b)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&eta;&mu;</sub>(C<sub>j</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  f<sub>&eta;&mu;</sub>(a, c)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&eta;&mu;</sub>(f<sub>&eta;&mu;</sub>(f<sub>&eta;&mu;</sub>(a, b), c), b) = f<sub>&eta;&mu;</sub>(a, c)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&eta;&mu;</sub>(f<sub>&eta;&mu;</sub>(a, b), b) = f<sub>&eta;&mu;</sub>(a, b)'));

?>