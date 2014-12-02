<?
$theory = '<table><tr><td align="center" width="100%">
  T<sub>5</sub> = C<sub>j</sub>(T<sub>5</sub>, &#8469;) |  C<sub>i</sub>(Bool, Bool)
  <br>
   
  T<sub>7</sub> = C<sub>n</sub>(T<sub>7</sub>) |  C<sub>m</sub>(&#8469;, &#8469;)
<br>
<br>
f<sub>&delta;&rho;</sub> : T<sub>5</sub> &times;  T<sub>7</sub> &#8594; T<sub>5</sub>
</td></tr></table>
<table>
<tr><td width="48%" align="right">
  f<sub>&delta;&rho;</sub>(C<sub>i</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  C<sub>i</sub>(b, b)
</td></tr>
<tr><td width="48%" align="right">
  f<sub>&delta;&rho;</sub>(C<sub>j</sub>(a, b), c)
</td><td width="4%" align="center">=</td><td width="48%" align="left">
  f<sub>&delta;&rho;</sub>(a, c)
</td></tr>
</table>

';

$theorems = array();
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&delta;&rho;</sub>(f<sub>&delta;&rho;</sub>(f<sub>&delta;&rho;</sub>(a, b), c), b) = f<sub>&delta;&rho;</sub>(a, c)'));
array_push($theorems,
           array('proof' => 'induction and rippling',
                 'statement' => 'f<sub>&delta;&rho;</sub>(f<sub>&delta;&rho;</sub>(a, b), b) = f<sub>&delta;&rho;</sub>(a, b)'));

?>