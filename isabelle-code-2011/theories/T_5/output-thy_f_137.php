<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>5</sub> = C<sub>j</sub>(T<sub>5</sub>, &#8469;) |  C<sub>i</sub>(Bool, Bool)
  <br>
   
  T<sub>8</sub> = C<sub>p</sub>(T<sub>8</sub>) |  C<sub>o</sub>(Bool, &#8469;)
<br>
<br>
f<sub>&delta;&omega;</sub> : T<sub>5</sub> &times;  T<sub>8</sub> &#8594; T<sub>5</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&delta;&omega;</sub>(C<sub>i</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>i</sub>(a, a)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&delta;&omega;</sub>(C<sub>j</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  f<sub>&delta;&omega;</sub>(a, c)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&delta;&omega;</sub>(f<sub>&delta;&omega;</sub>(f<sub>&delta;&omega;</sub>(a, b), c), b) = f<sub>&delta;&omega;</sub>(a, c)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&delta;&omega;</sub>(f<sub>&delta;&omega;</sub>(a, b), b) = f<sub>&delta;&omega;</sub>(a, b)'));

?>