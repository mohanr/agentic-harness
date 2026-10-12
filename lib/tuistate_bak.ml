(* https://blogs.perl.org/users/cyocum/2012/11/writing-state-monads-in-ocaml.html *)
(* https://www.cl.cam.ac.uk/teaching/1718/L28/10-monads.pdf *)

type state = { next : int }
(** a state is just a counter *)

type 'a t = state -> 'a * state
(** our monad is a state transition *)

(* now we write our monad API *)

let bind (t : 'a t) ~(f : 'a -> 'b t) : 'b t =
 fun state ->
  (* apply the first state transition first *)
  let a, transient_state = t state in
  (* and then the second *)
  let b, final_state = f a transient_state in
  (* return these *)
  (b, final_state)

let return (a : int) (state : state) = (a, state)

(* here's some state transition functions to help drive the example *)

let new_var _ (state : state) =
  let var = state.next in
  let state = { next = state.next + 1 } in
  (var, state)

let negate var (state : state) = (0 - var, state)
let add var1 var2 state = (var1 + var2, state)

(* Now we write things in an imperative way, without monads.
   Notice that we pass the state and return the state all the time, which can be tedious.
*)

let () =
  let run state =
    (* use the state to create a new variable *)
    let a, state = new_var () state in
    (* use the state to negate variable a *)
    let b, state = negate a state in
    (* use the state to add a and b together *)
    let c, state = add a b state in
    (* return c and the final state *)
    (c, state)
  in
  let init_state = { next = 2 } in
  let c, _ = run init_state in
  Format.printf "c: %d\n" c

(* We can write the same with our monad type [t]: *)

let () =
  let run =
    bind (new_var ()) ~f:(fun a ->
        bind (negate a) ~f:(fun b -> bind (add a b) ~f:(fun c -> return c)))
  in
  let init_state = { next = 2 } in
  let c, _ = run init_state in
  Format.printf "c2: %d\n" c

(* To understand what the above code gets translated to, we can inline the logic of the [bind] and [return] functions.
   But to do that more cleanly, we should start from the end and work backwards.
*)
let () =
  let run =
    (* fun c -> return c *)
    let _f1 c = return c in
    (* same as *)
    let f1 c state = (c, state) in
    (* fun b -> bind (add a b) ~f:f1 *)
    (* remember, [a] is in scope, so we emulate it by passing it as an argument to [f2] *)
    let f2 a b state =
      let c, state = add a b state in
      f1 c state
    in
    (* fun a -> bind (negate a) ~f:f2 a *)
    let f3 a state =
      let b, state = negate a state in
      f2 a b state
    in
    (* bind (new_var ()) ~f:f3 *)
    let f4 state =
      let a, state = new_var () state in
      f3 a state
    in
    f4
  in
  let init_state = { next = 2 } in
  let c, _ = run init_state in
  Format.printf "c3: %d\n" c

(* If we didn't work backwards, it would look like this: *)
let () =
  let run state =
    let a, state = new_var () state in
    (fun state ->
      let b, state = new_var () state in
      (fun state ->
        let c, state = add a b state in
        (fun state -> (c, state)) state)
        state)
      state
  in
  let init_state = { next = 2 } in
  let c, _ = run init_state in
  Format.printf "c4: %d\n" c
(* module Comp = struct *)
(*   type 'a t = action list -> ('a * action list) *)

(*   let (>>=) (x: 'a t) (f: 'a -> 'b t) : 'b t  = fun ls -> *)
(*     let (v, ls) = x ls in *)
(*     (f v) ls *)

(*   let get : action list t = (fun ls -> List.rev ls, ls) *)
(*   let put ls : unit t = (fun _ -> (), List.rev ls) *)
(*   let append action : unit t = (fun ls -> (), action :: ls) *)

(*   let return (x: 'a) : 'a t = (fun ls -> x, ls) *)

(*   let run (comp: 'a t) : 'a * action list = *)
(*     comp [] |> (fun (v, ls) -> (v, List.rev ls)) *)
(* end *)
(* let example_command : int t = *)
(*     let (let+) x f = (>>=) x f in *)
(*     let+ () = append "hello" in *)
(*     let+ () = append "world!" in *)
(*     return 30 *)
