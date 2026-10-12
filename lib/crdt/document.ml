open Types
open Containers
open Crdt

module Document = struct

type _ Effect.t += Effect_merger_error:  doc -> doc Effect.t

  (* Parameters are 'identity' and VersionMap *)
let check_version1 id version =
   let agent = get_agent id in
   let seq = get_seq  id in
    (* What is the highest sequence ? *)
              let highest_seq =
                (match (VersionMap.find_opt agent version) with
                           | Some v -> v >= seq
                           | None -> false
                           )
              in highest_seq

(* TODO What are the checks ? *)
let check_veracity_of_insertion item doc_content =
   let agent = get_agent item.id in
   let seq = get_seq  item.id in
   let contains_id id =
     List.exists
       (fun existing -> compare_identity existing.id id = 0)
       doc_content.doc_content
   in
 not (check_version1 item.id doc_content.version) &&
 (seq = 0 || check_version1 {agent = Some agent; seq = Some (seq - 1) }
                           doc_content.version)
 (* A version vector only says that this replica has seen a sequence number.
    The insertion algorithm needs the actual boundary item in its list.  In
    particular, accepting an origin merely because a later sequence number is
    present lets an item be inserted at the wrong index after an RPC merge. *)
 && (match item.origin_left with
    | None -> true
    | Some id -> contains_id id)
 && (match item.origin_right with
    | None -> true
    | Some id -> contains_id id)

let increment agent seq l1  =
let current_max = VersionMap.find_opt agent l1.version |> Option.value ~default:(-1) in
  VersionMap.add agent (max current_max seq) l1.version


let merge_both  src_content dest_content =

  let check_for_missing_content = (* What is this? *)
   List.filter ( fun item -> not (check_version1 item.id dest_content.version))
     src_content.doc_content |> List.map (fun v -> Some v) in
   let missing_content_length = List.length check_for_missing_content  in
  (* What is the length of this missing content ? *)

  let rec loop_while_outer doc i missing =
     (* Printf.printf "outer: i=%d, missing_len=%d, non_null=%d\n" *)
     (*  i missing_content_length *)
     (*  (List.length (List.filter Option.is_some missing)); *)
    if i > 0 then(
      let count,l, l1 =
      let rec loop_while_inner  j merged_count l l1 =
       if j < missing_content_length then (
        match List.nth l j with
        | None -> loop_while_inner (j + 1) merged_count l l1
        | Some item ->
        let valid = check_veracity_of_insertion item l1 in


        if not valid then

            loop_while_inner (j + 1) merged_count l l1
           else(
             let item_list = CRDTOp.Crdt_buffer.merge l1 item in
             (* 'List' requires this inefficient function. Array ? *)
             let updated_version = increment (get_agent item.id) (get_seq item.id) l1 in
             let new_doc =
             {
               doc_content = item_list ;
               version = updated_version
             }
             in
             let l =
             List.concat (
                 List.mapi (fun i x ->
                   if i = j then [None] else [x]
                 ) l
               ) in
             loop_while_inner  (j + 1)
                               (merged_count + 1) l new_doc
           )
        ) else merged_count,l, l1
        in
             loop_while_inner
                                 0
                                 0
                                 missing
                                 doc
          in
          if count = 0 then
            Effect.perform (Effect_merger_error doc)
          else
            loop_while_outer l1 (i - 1)  l
    ) else doc
    in
      (match loop_while_outer dest_content  missing_content_length  check_for_missing_content  with
        | effect Effect_merger_error v, _k -> let() = Printf.printf "Not merging properly"
                                                 in v
        | iteml -> iteml;
       )

let remote_merge_both  src_content =
      let doc = merge_both  src_content !CRDTOp.Crdt_buffer.doc_content_store in
      CRDTOp.Crdt_buffer.doc_content_store := doc;
      doc
end
