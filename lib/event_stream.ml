open Eio.Std
open Service_types
open Logger.Logger
open Tui_types
open Crdt.CRDTOp.Crdt_buffer
open Buffer
open Configurer
open Types
open Widget.Renderer
open Editorstate
open Editorcontext

module type STREAMER = sig
    val get_event_stream : unit -> key Eio.Stream.t
    val handle_event : Eio_unix.Stdenv.base ->Eio.Switch.t -> unit
    val cap_file_id : int ref
end

type _ Effect.t += ShowContent : doc ->  unit Effect.t

(*  TODO Make this reusable*)
module Ed : sig
    val init_state : string -> tui_editor_view
    val load_buffer : string -> tui_editor_view
  end = EditorContext (EditorState)
(*  TODO Make this reusable*)
module C : Configurer_intf.Configurer = struct
  include Configurer_intf.MakeConfigurer
  let set_size width height = { width; height }
end
module A = Area
module B = Buffer(A)
module BF = BufferManipulator (C) (B)

module EventStream :  STREAMER= struct
  let cap_file_id = ref (-1)
  let stream = Eio.Stream.create 20 (* Configure *)

  let get_event_stream() =
    stream

let run_client _env service =
  let open Crdtclient.Client in
  let open Lwt.Syntax in
  let open Core in
  let* merged_doc =
    mergedoc_doc service !doc_content_store in
    doc_content_store := merged_doc;
  let merged_items =
    List.map merged_doc.doc_content ~f:(fun item -> item.content)
    |> String.concat ~sep:""
  in
  let _ = log_m "Client received merged document [%s]\n" merged_items in
  Lwt.return merged_doc

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


  let update_data_in_buffer data ~env ~sw =
     let open Core in
     let _view = Ed.load_buffer data in(* Local replica's data *)
      let merged_doc = connect env#net env (* Initial call used to hold *)
                                                   (* the connection. *)
       (match (get_url (get_replica_cap_file !cap_file_id )) with
         | `Error _ -> failwith "Error in Uri.t"
         | `Ok o -> o) sw in
     let merged_content =
       List.map merged_doc.doc_content ~f:(fun item -> item.content)
       |> String.concat ~sep:""
     in
     let _view = Ed.load_buffer merged_content in
     merged_doc

let insert_local_doc i new_doc c =
    insert new_doc ("Text-" ^ string_of_int !cap_file_id) i c

  (* Effects for events/keystrokes *)
 let update_contents  doc (f : (key Eio.Stream.t -> key )) s =
   match f s  with
              | `ASCII c ->
                 (* let _ = log_m " Event picked up %c"  c in *)

                 (* A background sync may have replaced the replica since the
                    previous keypress. Insert into that current document. *)
                 let doc = !doc_content_store in
                 let doc = insert_local_doc ((List.length doc.doc_content ) + 1) doc (Char.escaped c) in
                 Effect.perform (ShowContent doc )

let handle_event env sw =
    let _ = log_m " handle_event"  in
    let open Core in

    let new_doc = make() in     (* Create 'doc' once *)
       Fiber.fork ~sw
         (fun () ->
          let rec loop doc  =
           let v =
              try
              (match  (update_contents  doc Eio.Stream.take  stream) with
              | effect ShowContent v, _k ->
                let merged_text =
                  List.map v.doc_content ~f:(fun item -> item.content)
                  |> String.concat ~sep:""
                  in
                    let merged_doc = update_data_in_buffer merged_text ~env ~sw in
                    render();
                    Fiber.yield ();
                    merged_doc
              | key -> doc)
               with End_of_file -> doc
                  | exn -> let _ = log_m "%s" (Exn.to_string exn) in doc
            in
            loop v (* v is out of scope *)
          in
          loop new_doc
         )
end
