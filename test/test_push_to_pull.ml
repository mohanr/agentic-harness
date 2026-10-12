open Effect
open Effect.Deep
type _ Effect.t += Next : int -> unit Effect.t

type 'a t = Leaf | Node of 'a t * 'a * 'a t

type result = Done
            | Result : int * (unit ->  result) -> result

let rec iter f = function
  | Leaf -> ()
  | Node (left, x, right) -> iter f left; f x; iter f right

let rec deep = function
  | 0 -> Leaf
  | n -> let t = deep (n - 1) in Node (t, n, t)

let long_tree = deep 18

let invert iter =
  fun () -> match iter (fun v -> Effect.perform (Next v)) with
  | () -> Done
  | effect Next v, k -> Result (v, Effect.Deep.continue k)


let%expect_test ""=
    let f = invert   (fun v -> iter v long_tree )     in
      (match f() with
        | Done -> ()
        |Result (v, _) -> Printf.printf "%d" v);
    [%expect {| 1 |}]





let to_gen (type a) (t : a t) iter =
  let module M = struct type _ Effect.t += Next : a -> unit Effect.t end in
  let open M in
  let step = ref (fun () -> assert false) in
  let first_step () =
    try
      iter (fun x -> perform (Next x)) t;
      None
    with effect Next v, k ->
      step := continue k;
      Some v
  in
    step := first_step;
    fun () -> !step ()

let%expect_test ""=
    let f = to_gen long_tree iter   in
    Printf.printf "%d" (match f()  with
                       |Some value -> value
                       |None -> 0
                       );
    [%expect {| 1 |}];
    Printf.printf "%d" (match f()  with
                       |Some value -> value
                       |None -> 0
                       );
    [%expect {| 2 |}]
