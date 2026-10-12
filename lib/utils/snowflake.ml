open Bigarray
open Int64
open Mtime.Span
open Eio

exception Monotonic_clock of string

type id = ID of int64
type node = {
	mu  :  Eio.Mutex.t;
	epoch : int64;
	node :   int64;
	mutable step :   int64;
	mutable time :   int64;

	nodemax :    int64;
	nodemask :   int64;
	stepmask :   int64;
	time_shift :  int64;
	node_shift :  int64;
}

let time_since () =
  let timedesc = Timedesc.make_exn ~tz:(Timedesc.Time_zone.make_exn "UTC") ~year:2010 ~month:11 ~day:4 ~hour:1 ~minute:42 ~second:54 () in
  let time_as_float =
      Timedesc.Span.sub (Timedesc.Timestamp.now()) ( Timedesc.to_timestamp_single timedesc)
  in Int64.of_float (Timedesc.Span.to_float_s time_as_float)
  (* Int64.of_float (Unix.gettimeofday()) *)


let node  =  Int64.of_int 10
let step  =  Int64.of_int 12
let epoch = Int64.of_int 1288834974657 (* epoch_millis need not be called everytime *)

let monotonic_clock =
   let now = Mtime_clock.now () in
   (* 1 second delay in nanoseconds *)
   let ns =  mul (rem epoch (of_int 1000))  (of_int 1000000) in
   (* convert a nanoseconds delay into a time span *)
   let time_ns = of_uint64_ns ns in
   let s = div  epoch (of_int 1000) in
   let time_s = of_uint64_ns s in

   (* compute target time *)
   let monotonic_addtimes =
   (match (Mtime.Span.abs_diff  (Mtime.Span.of_uint64_ns (Mtime.to_uint64_ns now))  (add time_s time_ns)) with
   |  m ->  Mtime.add_span now m
   (* | _ -> raise (Monotonic_clock "Date/Time error")                  (\* Throw an error ! *\) *)
   )
   in
    (match  monotonic_addtimes with
      |Some m -> Mtime.Span.of_uint64_ns (Mtime.to_uint64_ns m)
      | None -> raise (Monotonic_clock "Date/Time error") )                 (* Throw an error ! *)




let create_snowflake_node node=
    let mutex = Eio.Mutex.create() in
    (* node bites *)
    let node_bits_a= Array1.create int32 c_layout 1 in
    let _ = Array1.set node_bits_a 0  Int32.(logxor
                                  (neg (of_int 1))
                                  ( shift_left (neg (of_int 1)) (to_int (Array1.get node_bits_a 0)))) in
   let  nodemask  =  Int32.shift_left  (Array1.get node_bits_a 0) 12 in (*  step is repeated here*)
    (* step bites *)
    let step_bits_a= Array1.create int32 c_layout 1 in
    let _ = Array1.set step_bits_a 0 Int32.( logxor
                                  (neg (of_int 1))
                                  ( shift_left (neg (of_int 1)) (to_int (Array1.get step_bits_a 0)))) in
    let epoch_node = monotonic_clock  in


    let node_bits= Array1.get node_bits_a 0 in
    let step_bits= Array1.get step_bits_a 0 in
    {
        epoch     = Mtime.Span.to_uint64_ns epoch_node;
        node  =  node;
        step  =  0L;
        time =  0L;
        mu        = mutex;
        nodemax   = Int64.of_int32 node_bits;
        nodemask  =  Int64.of_int32 nodemask;

        stepmask   =  Int64.of_int32 step_bits;
        time_shift       = Int64.add  (Int64.of_int32 node_bits)   (Int64.of_int32 step_bits);
        node_shift       =  (Int64.of_int32 step_bits);
    }


let generate n  =
   (* Printf.printf "Generating Snowflake Id\n"; *)

   Eio_main.run @@ fun env ->
   Eio.Switch.run @@ fun sw ->
   let clock = Eio.Stdenv.clock env in
   let id =
   Fiber.fork_promise ~sw (fun () ->
   Eio.Mutex.use_rw ~protect:true n.mu (fun () ->

       let  gen_id  node =
         let  milli  =  time_since () in
         if  Int64.equal milli node.time then(
             node.step <- Int64.logand (Int64.add node.step  (Int64.of_int 1))  node.stepmask;

             (* Fmt.pr " node.step  %Ld\n"  node.step; *)

             if Int64.equal node.step 0L then(
                 let rec loop_while() =

                  let  millis  =  time_since () in
                  if Int64.compare millis node.time <= 0 then(
                     Eio.Time.sleep clock 0.00005;
                     loop_while() ;
                  )
                  else millis
                 in
                 let new_millis = loop_while() in
                 node.time <- new_millis;
             );
         )else(
             (* Fmt.pr " node.step is set to %Ld\n"  0L; *)
             node.step <- 0L;
             (* Fmt.pr " node.time is set from %Ld to %Ld\n" node.time milli; *)
             node.time <-   milli;

         );
         let id =
         ID  (Int64.( logor (logor (shift_left node.time  (to_int node.time_shift))
             (shift_left node.node  (to_int node.node_shift)))
             node.step)) in
           (* Fmt.pr "%Ld\n" (match id with | ID x -> x); *)
         match id with | ID x -> x
        in gen_id n
        )
	) in Promise.await id
