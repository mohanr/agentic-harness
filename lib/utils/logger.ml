open Lwt.Infix
open Stdlib

module Logger = struct
(* let file_reporter file = *)
(*   let oc = *)
(*     open_out_gen [Open_creat; Open_append; Open_text] 0o644 file *)
(*   in *)
(*   let fmt = Format.formatter_of_out_channel oc in *)

(*   let report _src _level ~over k msgf = *)
(*     msgf @@ fun ?header:_ ?tags:_ fmt_msg -> *)
(*       Format.kfprintf *)
(*         (fun _ -> *)
(*           Format.pp_print_flush fmt (); *)
(*           flush oc; *)
(*           over (); *)
(*           k () *)
(*         ) *)
(*         fmt fmt_msg *)
(*   in *)
(*   { Logs.report } *)
let lwt_reporter file =
  let buf_fmt ~like =
    let b = Buffer.create 512 in
    Fmt.with_buffer ~like b,
    fun () -> let m = Buffer.contents b in Buffer.reset b; m
  in
  let app, app_flush = buf_fmt ~like:Fmt.stdout in
  let dst, dst_flush = buf_fmt ~like:Fmt.stderr in
  let reporter = Logs_fmt.reporter ~app ~dst () in
  let report src level ~over k msgf =
    let k () =
       let write () =
         Lwt_io.open_file ~flags:[Unix.O_WRONLY; Unix.O_CREAT; Unix.O_APPEND]
           ~perm:0o777 ~mode:Lwt_io.Output file
        >>= fun fd -> (
          match level with
          | Logs.App -> Lwt_io.write fd (app_flush ())
          | _ -> Lwt_io.write fd (dst_flush ())
        )
          >>= fun () ->
            Lwt_io.close fd
    in
     let unblock () = over (); Lwt.return_unit in
      Lwt.finalize write unblock |> Lwt.ignore_result;
      k ()
    in
    reporter.Logs.report src level ~over:(fun () -> ()) k msgf;
  in
  { Logs.report = report }

 let setup cmid =
  let open Eio.Std in
  traceln "Log reporter setup";
  Logs.set_reporter (lwt_reporter  ("/Users/anu/Documents/rays/raft1/raft" ^ (Int.to_string cmid ) ^ ".log"));
  Logs.set_level (Some Debug);
  Lwt.return_unit


let pp_log out x = Format.fprintf out "\n%s" x
let pp_log3 out node_id = Format.fprintf out "\nSnowflake Node ID is %d" node_id
let pp_log4 out v n n1 n2 =  Format.fprintf out "\nVoting procedure [current Term=%d, Candidate voted for =%d,
 log index/term=(%d, %d)]" v n n1 n2
let pp_log5 out vote candidate_id =
  Format.fprintf out "\nVoted %b for  %d" vote candidate_id
let pp_log6 out term cmid  index term1= Format.fprintf out "\nVoting procedure [Index=%d, Candidate ID =%d,
 ,term=%d,term at last log=%d]" index cmid term term1
let pp_log7 out vote term current_term =
  Format.fprintf out "\nTallied Vote obtained %b for term [%ld],Current term[%d]" vote term current_term
let pp_log8 out s id =
  Format.fprintf out "\n[%d] in check election state - state is %s" id s
let pp_log9 out s  =
	Format.fprintf out  "\nReplicated log received (by) %s " s
let pp_log10 out t t1  =
	Format.fprintf out  "\nTerm started  %d Current term %d " t t1
let pp_log11 out s  =
	Format.fprintf out  "\nElection started by  %d " s
let pp_log12 out id votes_received  =
   Format.fprintf out  "\n%d wins election with %d votes" id votes_received
let pp_log13 out t id  =
 Format.fprintf out "\n%d Becomes candidate with current term - %d" id t
let pp_log14 out t id  =
 Format.fprintf out "\n Map contains - %d entries. Does it contain the current entry ? [%b]" t id
let pp_log_time out time_as_ns=
 Format.fprintf out "\n[ Timeout Duration: %.2f ]"  time_as_ns


let pp_log_time1 out elapsed_time=
 Format.fprintf out "\n[ Elapsed Time: %.2f ]\n"  (Timedesc.Span.to_float_s elapsed_time)

let pp_log15 out t   =
 Format.fprintf out "\n  [%d] compare elapsed_time  timeout_duration) " t

let pp_log16 out term candidate_id index_at_last_log term_at_last_log
   current_term voted_for saved_term_at_last_log index =
 Format.fprintf out "\n Voting procedure ([%d]term  == [%d]current_term &&
               ( [%d]!voted_for == -1 || [%d]!voted_for == [%d]candidate_id) &&
              ([%d]term_at_last_log > [%ld](Int32.to_int saved_term_at_last_log) ||
              ([%d]term_at_last_log == [%ld](Int32.to_int saved_term_at_last_log)
                   && [%d]index_at_last_log >= [%d]index))) "
   term current_term voted_for voted_for candidate_id  term_at_last_log saved_term_at_last_log
   term_at_last_log saved_term_at_last_log index_at_last_log index

let raft_tag : string Logs.Tag.def =
  Logs.Tag.def "\nraft" ~doc:"Raft log" pp_log

let stamp  = Logs.Tag.(empty |> add raft_tag "\nRAFT")

let log_m message  =
  Logs_lwt.app(fun m -> m ~tags:(stamp)  message)

let log_m fmt =
  Format.kasprintf (fun s -> Logs_lwt.app (fun m -> m ~tags:stamp "%s" s)) fmt

let pp_log1 out t  =
  Format.fprintf out "\n becomes Follower with term %ld " t

let pp_log2 out state = Format.fprintf out "\nState when commit log was received %s " state

let log_message1 args pp =
  Logs_lwt.app @@ fun m ->
  args (fun k n  -> m ~tags:(stamp) " %a %a" pp  k pp n )

let log_message2 args pp =
  Logs_lwt.app @@ fun m ->
  args (fun k n n1 n2 -> m ~tags:(stamp)
         "  %a "  (fun out () -> pp out   k  n  n1  n2 )())

let log_message args pp =
  Logs.app @@ fun m ->
  args (fun k   -> m ~tags:(stamp) " %a"    pp k)

let log_message3 args pp =
  Logs.app @@ fun m ->
  args (fun i t c  -> m ~tags:(stamp) " %a " (fun out () -> pp out i t c) ())

let log_message4 args pp =
  Logs.app( fun m ->
  args (fun i t -> m ~tags:stamp " %a " (fun out () -> pp out i t) ())
   )

let log_message5 args pp =
  Logs.app( fun m ->
  args (fun i t  -> m ~tags:stamp " %a " (fun out () -> pp out i t ) ())
   )

let log_message6 args pp =
  Logs.app( fun m ->
  args (fun i t -> m ~tags:stamp " %a " (fun out () -> pp out i t) ())
   )

let log_message7 args pp =
  Logs_lwt.app @@ fun m ->
  args (fun term candidate_id index_at_last_log term_at_last_log
            current_term voted_for saved_term_at_last_log index-> m ~tags:(stamp)
         "  %a "  (fun out () -> pp out term candidate_id index_at_last_log term_at_last_log
                                        current_term voted_for saved_term_at_last_log index)())
end
