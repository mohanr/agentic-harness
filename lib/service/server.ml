open Eio.Std
open Snowflake
open Service_types
open Tuiservice
open Tuioperator
open Logger.Logger

(* Adapted from my Raft multi-node code *)
type single_node = {
    no_of_nodes : int;
	server_cap_files : string list;
}
[@@deriving_show]


let snowflake_id = ref 0
module type Node = Configurer_intf.Node


let create_config_node env no cap_file_id  : (module Node)=

let node = create_snowflake_node (Int64.of_int 0) in
 let cap_id_map =
  let rec loop_while  i map =
    if i < no then(
      let path = ( "/Users/anu/Documents/rays/collaborative-editor/lib/mergedoc/"
                   ^ ( Int.to_string cap_file_id ) ^ ".cap") in
        let id = generate node in
        let map = EntryMap.add
         (match id with | Ok v ->  snowflake_id := Int64.to_int v;
           (* Snowflake ID is part of the log file name *)
                     Logs.set_reporter (lwt_reporter
                       ("/Users/anu/Documents/rays/collaborative-editor/" ^
                        ( Int.to_string !snowflake_id ) ^ ".log"));
                     Int64.to_int v;
                        | Error _ -> failwith
                                         "Unable to get snowflake id")
        path map in
      loop_while (i + 1) map
    ) else map
  in
  loop_while 0 EntryMap.empty in
  let module Config_node = struct
    let cap_id_map = cap_id_map
    let env = env
  end in
  (module Config_node: Node )


let  new_cluster no_of_nodes env sw la cap_file_id =
   let n = create_config_node env no_of_nodes cap_file_id in
   let module Config_Node = (val n  : Configurer_intf.Node)  in
   let listen_address = [`TCP ("127.0.0.1", (int_of_string la)) ] in

   let list_of_servers =
   let rec loop_while lad p i =

    if i < no_of_nodes then(
      let path = ( "/Users/anu/Documents/rays/collaborative-editor/lib/mergedoc/" ^ ( Int.to_string cap_file_id ) ^ ".cap") in

      (* Printf.printf "Generating snowflake Id"; *)

      let module TuiService = TuiService.Make(TUIOp) in
      Fiber.fork_daemon ~sw ( fun () ->
           let _ = log_m "[%s %d]" la cap_file_id in
          ignore(TuiService.start_server  env#net env  (List.nth lad i) path
                   (match (reverse path Config_Node.cap_id_map ) with
                    | Some k -> k
                    |None ->
                      List.iter (fun  (k, v) ->
                        Printf.printf "Wrong cap file name/path %d %s" k v
                          ;) ( EntryMap.bindings Config_Node.cap_id_map);
                             failwith "Wrong cap file name/path"));
          `Stop_daemon

      );
      (* Printf.printf "\nNode %d\n" i; *)

      loop_while lad ( p @ [path]) (i + 1)
    )
    else p
   in
   loop_while listen_address [] 0
   in
	 {
      no_of_nodes = no_of_nodes;
      server_cap_files = list_of_servers;
	 }



let run_client _env service =
  let open Crdtclient.Client in
  let open Crdt in
  let open Lwt.Syntax in
  let open Core in
  (* TODO LET* *)
  let* items =
    mergedoc service !CRDTOp.Crdt_buffer.doc_content_store in
    let merged_items =
    (List.map items ~f:(fun item ->
                  item)
                  |> String.concat ~sep:"") in
     let _ = log_m "Client invoked RPC and received %s\n" merged_items in
     Lwt.return merged_items

let connect net env uri sw =
  try
  (* Switch.run @@ fun sw -> *)
  let client_vat = Capnp_rpc_unix.client_only_vat ~sw net in
  let sr = Capnp_rpc_unix.Vat.import_exn client_vat uri in
  Capnp_rpc_unix.with_cap_exn  sr (fun cap -> Lwt_eio.run_lwt
                                (let merged_content= run_client env cap in
                                (fun () -> merged_content)));

   with
     | Eio.Cancel.Cancelled _exception as exn ->
                                            let _ = log_m "Connect failure(Eio) "
                                            in ();  raise exn
     | Lwt.Canceled ->
      let _ = log_m "Connect failure (Lwt)" in
      raise Lwt.Canceled

let boot_server listen_address cap_file_id =
  let open Event_stream in
  EventStream.cap_file_id := cap_file_id; (* CONNECT using this again in another fibre *)
  Eio_main.run @@ fun env ->
  Lwt_eio.with_event_loop ~clock:(Eio.Stdenv.clock env) @@ fun () ->
  Eio.Switch.run (fun sw ->
  Logs.set_level (Some Debug);
  (* Waiting here to allow the server to start properly *)
  let new_cluster = new_cluster 1 env sw listen_address cap_file_id in
  let t = Timedesc.Span.make  ~s:95L () in
  Eio.Time.sleep (Eio.Stdenv.clock env) (Timedesc.Span.to_float_s t) ;
  let rec loop_while  i  =
  if i < new_cluster.no_of_nodes then(
  let t = Timedesc.Span.make  ~s:30L () in
  Eio.Time.sleep (Eio.Stdenv.clock env) (Timedesc.Span.to_float_s t) ;
  let _ = log_m "Connect to %d for %d " new_cluster.no_of_nodes cap_file_id in
      let _merged_content = connect env#net env (* Initial call used to hold *)
                                                   (* the connection. *)
       (match (get_url (get_replica_cap_file cap_file_id )) with
         | `Error _ -> failwith "Error in Uri.t"
         | `Ok o -> o) sw in
      loop_while  (i + 1));
  in
  loop_while 0;
  (* Eio.Switch.fail sw (Failure "Normal test cancellation"); *)
  Eio.Fiber.await_cancel ()
  )
