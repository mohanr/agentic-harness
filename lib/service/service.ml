open Capnp_rpc_lwt
open Lwt.Infix
open Types
open Logger.Logger
open Document.Document


module MergeApi = Merge.MakeRPC(Capnp_rpc_lwt)

module MergeService (CRDTOp : CRDTOperator ) = struct

let merge_local =
  let module Merge= MergeApi.Service.MergeDoc in
  Merge.local @@ object
    inherit Merge.service

    method mergedoc_impl params release_param_caps =
      let _ = log_m "Merge document RPC implementation" in
      release_param_caps ();
      let open MergeApi.Reader in
      let open MergeApi.Reader.MergeDoc.Mergedoc in
      let extract_item item_list =
        let id i =
          let identity = Item.id_get i in
          {
            agent = Some (Ident.agent_get identity) ;
            seq = Some (Ident.seq_get identity) ;
          }
        in
        let il =
                    List.fold_left
                    (fun acc i ->
                      {
                        content =Item.content_get i;
                        id = id i;
                        origin_left =
                                            (
                                             match IdentityU.Message.get (IdentityU.message_get
                                                                           (Item.originleft_get i)) with
                                                IdentityU.Message.Someidentity identity ->

                                                   Some(
                                                     {
                                                       agent = Some (
                                                                match AgentU.Message.get (AgentU.message_get(
                                                                  Identity.agent_get identity)) with
                                                               | Someagent s -> s
                                                               | Noneagent -> String.empty
                                                               | _ -> failwith "origin left is missing"
                                                               ) ;
                                                       seq = Some (
                                                                match SeqU.Message.get (SeqU.message_get(
                                                                  Identity.seq_get identity)) with
                                                               | Someseq s -> s
                                                               | Noneseq -> 0
                                                               | _ -> failwith "origin right is missing"
                                                               ) ;
                                                     }
                                                   )
                                              | IdentityU.Message.Noneidentity  -> None
                                              | _ -> failwith "origin left is missing"
                                            );
                        origin_right =
                                            (
                                             match IdentityU.Message.get (IdentityU.message_get
                                                                           (Item.originright_get i)) with
                                                IdentityU.Message.Someidentity identity ->
                                                   Some(
                                                     {
                                                       agent = Some (
                                                                match AgentU.Message.get (AgentU.message_get(
                                                                  Identity.agent_get identity)) with
                                                               | Someagent s -> s
                                                               | Noneagent -> String.empty
                                                               | _ -> failwith "origin right is missing"
                                                               ) ;
                                                       seq = Some (
                                                                match SeqU.Message.get (SeqU.message_get(
                                                                  Identity.seq_get identity)) with
                                                               | Someseq s -> s
                                                               | Noneseq -> 0
                                                               | _ -> failwith "origin right is missing"
                                                               ) ;
                                                     }
                                                   )
                                              | IdentityU.Message.Noneidentity  -> None
                                              | _ -> failwith "Origin left is missing"
                                            );
                        deleted = false; (* Not used now *)
                      }
                     :: acc) [] item_list
                    |> List.rev
        in il
      in
      let item_list = extract_item (Params.itemlist_get_list params) in
      let doc_content = Params.doccontent_get_list params in
      let new_map = VersionMap.empty in
      let version_map =
                  List.fold_left
                  (fun acc kv -> VersionMap.add
                      (VersionTuple.key_get kv)
                      (VersionTuple.value_get kv)
                      acc)
                  new_map
                  doc_content in
      let response, results = Service.Response.create
          MergeApi.Service.MergeDoc.Mergedoc.Results.init_pointer in
      (* Call the service *)
      let doc = Document.Document.remote_merge_both (*  Nor RPC call *)
                                                        (*  as this is the *)
                                                        (*  service.It takes *)
                                                        (*  a source doc(Replica 1) and gets *)
                                                        (*  back a merger doc(from *)
                                                        (*  Replica 2 ). *)
                                 { doc_content = item_list;
                                   version = version_map } in

      let item_builder = MergeApi.Service.MergeDoc.Mergedoc.Results.itemlist_init
                                                            results
                                                            (List.length doc.doc_content) in
      let version_builder = MergeApi.Service.MergeDoc.Mergedoc.Results.doccontent_init
                                                            results
                                                            (VersionMap.cardinal doc.version) in
      let open MergeApi.Builder in
      (* let _ = MergeApi.Service.MergeDoc.Mergedoc.Results.itemlist_set_list  results [] in *)
      (* let _ = MergeApi.Service.MergeDoc.Mergedoc.Results.doccontent_set_list  results [] in *)
      List.iteri (fun i item ->
                              let allocated_i = Capnp.Array.get item_builder i  in
                              Item.content_set  allocated_i item.content;
                              let id = Item.id_init  allocated_i  in
                              let () = Ident.agent_set  id (match item.id.agent with None -> String.empty| Some a -> a) in
                              Ident.seq_set_exn  id (match item.id.seq with None -> 0| Some a -> a ); (* TODO 0 could be valid *)
                              let ol = Item.originleft_init  allocated_i  in
                              let idu = IdentityU.message_init ol in
                              let () =
                              (match item.origin_left with
                              | None -> IdentityU.Message.noneidentity_set idu
                              | Some v -> let some_idu = IdentityU.Message.someidentity_init idu in
                                          let a = Identity.agent_init some_idu in
                                          let au = AgentU.message_init a in
                                          let () =
                                            (match v.agent with
                                              |None -> AgentU.Message.noneagent_set au
                                              |Some agent ->  AgentU.Message.someagent_set au agent ) in
                                          let s = Identity.seq_init some_idu in
                                          let su = SeqU.message_init s in
                                          let () =
                                            (match v.seq with
                                              |None -> SeqU.Message.noneseq_set su
                                              |Some seq -> SeqU.Message.someseq_set_exn su seq ) in ()

                              ) in
                              let or_r = Item.originright_init  allocated_i  in
                              let idu_r = IdentityU.message_init or_r in
                              let () =
                               (match item.origin_right with
                              | None -> IdentityU.Message.noneidentity_set idu_r
                              | Some v -> let some_idu = IdentityU.Message.someidentity_init idu_r in
                                          let a = Identity.agent_init some_idu in
                                          let au = AgentU.message_init a in
                                          let () =
                                            (match v.agent with
                                              |None -> AgentU.Message.noneagent_set au
                                              |Some agent ->  AgentU.Message.someagent_set au agent ) in
                                          let s = Identity.seq_init some_idu in
                                          let su = SeqU.message_init s in
                                          let () =
                                            (match v.seq with
                                              |None -> SeqU.Message.noneseq_set su
                                              |Some seq -> SeqU.Message.someseq_set_exn su seq ) in ()
                              )
                              in
                              Item.deleted_set  allocated_i item.deleted;

                              ) doc.doc_content ;
      List.iteri (fun i (k, v) ->
                              let allocated_v = Capnp.Array.get version_builder i  in
                              let () = MergeApi.Builder.VersionTuple.key_set allocated_v k in
                              MergeApi.Builder.VersionTuple.value_set_exn allocated_v v
                           ) (VersionMap.bindings doc.version) ;
      Service.return response

end
end

module MergeClient = struct
module Merge = MergeApi.Client.MergeDoc.Mergedoc

(** [foo_set_list s v] sets the content of field [foo] from OCaml list [v].
    (This may result in reallocation of [foo], which may lead to poor
    performance.)

    @return a reference to the content of field [foo]

    @raise Message.Invalid_message if the message is ill-formatted *)
(* val foo_set_list : t -> Inner.t list -> (rw, Inner.t, 'b) Capnp.Array.t *)

let mergedoc t doc =
  let open Merge in
  let request, params = Capability.Request.create Params.init_pointer in
  let item_builder = Params.itemlist_init params
                                            (List.length doc.doc_content) in
  let version_builder = Params.doccontent_init params
                                            (VersionMap.cardinal doc.version) in
  let open MergeApi.Builder in
  List.iteri (fun i item ->
                              let allocated_i = Capnp.Array.get item_builder i  in
                              Item.content_set  allocated_i item.content;
                              let id = Item.id_init  allocated_i  in
                              let () = Ident.agent_set  id (match item.id.agent with None -> String.empty| Some a -> a) in
                              Ident.seq_set_exn  id (match item.id.seq with None -> 0| Some a -> a ); (* TODO 0 could be valid *)
                              let ol = Item.originleft_init  allocated_i  in
                              let idu = IdentityU.message_init ol in
                              let () =
                              (match item.origin_left with
                              | None -> IdentityU.Message.noneidentity_set idu
                              | Some v -> let some_idu = IdentityU.Message.someidentity_init idu in
                                          let a = Identity.agent_init some_idu in
                                          let au = AgentU.message_init a in
                                          let () =
                                            (match v.agent with
                                              |None -> AgentU.Message.noneagent_set au
                                              |Some agent ->  AgentU.Message.someagent_set au agent ) in
                                          let s = Identity.seq_init some_idu in
                                          let su = SeqU.message_init s in
                                          let () =
                                            (match v.seq with
                                              |None -> SeqU.Message.noneseq_set su
                                              |Some seq -> SeqU.Message.someseq_set_exn su seq ) in ()

                              ) in
                              let or_r = Item.originright_init  allocated_i  in
                              let idu_r = IdentityU.message_init or_r in
                              let () =
                               (match item.origin_right with
                              | None -> IdentityU.Message.noneidentity_set idu_r
                              | Some v -> let some_idu = IdentityU.Message.someidentity_init idu_r in
                                          let a = Identity.agent_init some_idu in
                                          let au = AgentU.message_init a in
                                          let () =
                                            (match v.agent with
                                              |None -> AgentU.Message.noneagent_set au
                                              |Some agent ->  AgentU.Message.someagent_set au agent ) in
                                          let s = Identity.seq_init some_idu in
                                          let su = SeqU.message_init s in
                                          let () =
                                            (match v.seq with
                                              |None -> SeqU.Message.noneseq_set su
                                              |Some seq -> SeqU.Message.someseq_set_exn su seq ) in ()
                              )
                              in
                              Item.deleted_set  allocated_i item.deleted;
                              ) doc.doc_content ;
      List.iteri (fun i (k, v) ->
                              let allocated_v = Capnp.Array.get version_builder i  in
                              let () = MergeApi.Builder.VersionTuple.key_set allocated_v k in
                              MergeApi.Builder.VersionTuple.value_set_exn allocated_v v
                           ) (VersionMap.bindings doc.version) ;
  Capability.call_for_value_exn t method_id request >|=fun response ->
   ( Merge.Results.itemlist_get response,
     Merge.Results.doccontent_get_list response)          (* CCMap  *)
end
