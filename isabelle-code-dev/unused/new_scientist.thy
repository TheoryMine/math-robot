theory new_scientist
imports "tm_datatypes"
begin

-- "New Scientist datatype is Ts:  Ts := C_ak Ts | C_al N"

term "C_ak" 
term "C_al"

ML {*
val t1 = @{term "Trueprop (f (C_al n) (y :: Ts) = y)"};
val t2 = @{term "Trueprop (f (C_ak x) (y :: Ts) = C_ak (f x y))"};
val rec_ty_name = "Ts";
val funtion_name = "f";
*}

setup {* MakeFun.add_new_function Fn.default_name [t1,t2] *}
print_theorems

lemmas rules = f_a.simps

lemmas wrules[wrule] = rules 

lemma zero_right[wrule,simp]: "f_a (f_a x (C_al n)) z = f_a x z"
apply (rippling)
done

lemma suc_right[wrule,simp]: "f_a x (C_ak y) = C_ak (f_a x y)"
apply (rippling)
done

lemmas f_a.simps[wrule]
theorem left_commute_of_f_a[wrule]: "f_a (f_a x y) z = f_a (f_a y x) z"
proof (induct y arbitrary: x)
  fix nat x
  show "f_a (f_a x (C_al nat)) z = f_a (f_a (C_al nat) x) z"
    apply simp
    done
next
  fix y x
  assume IH: "!! x. f_a (f_a x y) z = f_a (f_a y x) z"
  show "f_a (f_a x (C_ak y)) z = f_a (f_a (C_ak y) x) z"
    apply (simp add: IH)
done


apply (rippling)
done

  assume "f_a (f_a x y) z = f_a (f_a y x) z" 
  show "f_a (f_a (C_ad x bool) y) z = f_a (f_a y (C_ad x bool)) z"

