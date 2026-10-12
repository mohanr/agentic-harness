open Service
open Types
(* https://www.youtube.com/watch?v=HNLSyxN-rPE *)

module MergeApi = Merge.MakeRPC(Capnp_rpc_lwt)

module Client = struct
let doc_of_reply (item_list, version_list) =
  let open MergeApi.Reader in
  let identity i =
    let id = Item.id_get i in
    {
      agent = Some (Ident.agent_get id);
      seq = Some (Ident.seq_get id);
    }
  in
  let origin get_origin i =
    match IdentityU.Message.get (IdentityU.message_get (get_origin i)) with
    | IdentityU.Message.Someidentity id ->
      let agent =
        match AgentU.Message.get (AgentU.message_get (Identity.agent_get id)) with
        | AgentU.Message.Someagent value -> value
        | AgentU.Message.Noneagent -> String.empty
        | _ -> failwith "Invalid origin agent"
      in
      let seq =
        match SeqU.Message.get (SeqU.message_get (Identity.seq_get id)) with
        | SeqU.Message.Someseq value -> value
        | SeqU.Message.Noneseq -> 0
        | _ -> failwith "Invalid origin sequence"
      in
      Some { agent = Some agent; seq = Some seq }
    | IdentityU.Message.Noneidentity -> None
    | _ -> failwith "Invalid origin"
  in
  let doc_content =
    Capnp.Array.fold item_list ~init:[] ~f:(fun acc i ->
      {
        content = Item.content_get i;
        id = identity i;
        origin_left = origin Item.originleft_get i;
        origin_right = origin Item.originright_get i;
        deleted = Item.deleted_get i;
      } :: acc)
    |> List.rev
  in
  let version =
    List.fold_left (fun acc kv ->
      VersionMap.add (VersionTuple.key_get kv) (VersionTuple.value_get kv) acc)
      VersionMap.empty version_list
  in
  { doc_content; version }

let mergedoc service doc =
         let open Lwt.Infix in
         let open MergeApi.Reader in
         let result = MergeClient.mergedoc service doc in
         result >>=fun reply ->
         (* let l =  (reply :> (Merge.rw, 'a, 'b) Capnp__InnerArray.t) in *)
         let (item_list, _version) = reply in
         let items = Capnp.Array.fold item_list~init:[]
                    ~f:(fun acc i ->
                        (Item.content_get i) :: acc
                     )   in
         Lwt.return items

let mergedoc_doc service doc =
  let open Lwt.Infix in
  MergeClient.mergedoc service doc >|= doc_of_reply


end
