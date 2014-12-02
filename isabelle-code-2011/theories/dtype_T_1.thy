theory "dtype_T_1"
imports rename
begin

text {*  
  T_1 := C_1(N,N) | C_2(T_1,N)
*}
datatype "T_1" = "C_1" "nat" "nat" | "C_2" "T_1" "nat"

end;
