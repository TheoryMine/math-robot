<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>1</sub> = C<sub>b</sub>(T<sub>1</sub>, &#8469;) |  C<sub>a</sub>(&#8469;, &#8469;)
<br>
<br>
f<sub>&alpha;&nu;</sub> : T<sub>1</sub> &times;  &#8469; &#8594; &#8469;
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&alpha;&nu;</sub>(C<sub>a</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  c
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&alpha;&nu;</sub>(C<sub>b</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  f<sub>&alpha;&nu;</sub>(a, Suc(f<sub>&alpha;&nu;</sub>(a, f<sub>&alpha;&nu;</sub>(a, zero))))
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&alpha;&nu;</sub>(a, Suc(f<sub>&alpha;&nu;</sub>(a, f<sub>&alpha;&nu;</sub>(a, zero)))) = Suc(zero)'));

?>