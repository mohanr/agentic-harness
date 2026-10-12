open Effect
open Effect.Deep
open Types
(* https://github.com/ocaml-multicore/effects-examples/blob/master/state.ml *)

module type TYPE = sig
  type t
end

module type STATE = sig
  type t

  val get : unit -> t
  val set : t -> unit
  val store : init:t ->  (unit -> 'a) -> t * 'a
end

module type DOC_CONTENT_STORE = functor (T : TYPE) -> STATE with type t = T.t

module Localdoc: DOC_CONTENT_STORE = functor (T : TYPE) -> struct
  type t = T.t
  type _ eff += Get : t eff | Set : t -> unit eff

  let get () = perform Get
  let set y = perform (Set y)

  let store (type a) ~init (new_content : unit -> a) : t * a =
    (match new_content () with
     | res -> fun x -> (x, res)
     | effect Get, k -> fun (x : t) -> continue k x x
     | effect (Set y), k -> fun (_x : t) -> continue k () y) init
end

module DocContent= Localdoc (struct
  type t = doc
end)

let new_content doc : unit =
  DocContent.(
    set doc;
  )
let update_doc doc =
  ignore  (  DocContent.store ~init:doc (fun () -> new_content doc))
