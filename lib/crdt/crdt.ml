open Types
open Effect.Deep
open Logger.Logger
(* https://xavierleroy.org/CdF/2023-2024/5.pdf *)
module Crdt = struct

  module Crdt_buffer = struct

   (* exception Version_error of string *)

   (* Local store before merging *)
   let doc_content_store = ref
                           {
                           doc_content = [];
                           version = VersionMap.empty;                   (* CCMap  *)
                           }
   type _ eff += Failure : string -> item eff

   let get_safe_list_elt doc pos  =
     try

       List.nth doc.doc_content pos

     with Failure arg ->
       let open Sexplib in
       (* let _ = log_m "(Benign)There is no character at position %d\n" pos in *)
       (* List.iter (fun v -> *)
        (* let _ = log_m  "Content %a\n" Sexp.pp_hum ([%sexp_of: item] v ) in ()) *)
        (*                                            doc.doc_content ; *)
       Effect.perform (Failure arg )

   let get_left_or_right_elt doc pos =
      if pos < 0 then None
      else
        match get_safe_list_elt doc pos with
        | item -> Some item.id
        | effect Failure s, k ->
          None


    type _ Effect.t += Early_return :  int -> int Effect.t
    let make() =
      {
        doc_content = [];
        version = VersionMap.empty
      }

    let content c =
      let list  = List.filter (fun item ->
                               Bool.equal  item.deleted false) c in
      let contents =
            let rec loop_while l1 l2 =
            match l2 with
                   | {content = c;_}:: tl->
                    loop_while ( l1 @ [c]) tl
                   | [] -> l1
            in loop_while [] list
     in contents

    let find_index doc_content = function
      | None -> -1
      | Some id ->
        let id_found = List.find_mapi (fun i item ->
          if compare_identity item.id id = 0 then Some (i, item) else None
        ) doc_content in
        match id_found with
        | Some (index, _) -> index
        | None -> -1

    (* Example effect handler *)
    (* let tree_enum (type elt) : elt tree -> elt enum = *)
         (* let module Inv = struct *)
         (* type _ eff += Next : elt -> unit eff *)
         (* let tree_enum (t: elt tree) : elt enum = *)
         (* match tree_iter (fun x -> perform (Next x)) t with *)
         (* | () -> Done *)
         (* | effect Next x, k -> More(x, fun () -> continue k ()) *)
         (* end in *)
         (* Inv.tree_enum *)
    let check_version doc agent =

      let version_option =                   (* CCMap *)
        VersionMap.find_opt agent doc.version in
      let seq = (match version_option with
                 | Some v -> v + 1
                 | None -> 0
                 )
      in seq

    let merge doc new_item =
      let identity = new_item.id in
      if (check_version doc (get_agent identity))
                           <> get_seq identity
          then failwith "Last seq is not correct"
      else

      let left = find_index doc.doc_content new_item.origin_left in
      let left_index = left + 1 in
            let right = (match new_item.origin_right with
                         | Some id ->
                           find_index doc.doc_content (Some id)
                         | None -> List.length doc.doc_content
                        )
            in
            let rec loop_while i idx scanning =
              let idx =
              if not scanning then
                i
              else
                idx in

                if i = List.length doc.doc_content || i = right then
                  Effect.perform ( Early_return  idx)
                else(
                  let other = List.nth doc.doc_content i in
                  let other_left =
                           find_index doc.doc_content other.origin_left
                  in
                  let other_right =
                  (match other.origin_right with
                               | Some value ->
                                find_index doc.doc_content (Some value)
                               | None -> List.length doc.doc_content)
                  in

                  if ( other_left < left ) || ((other_left = left) &&
                     (other_right= right) &&
                    (String.compare (get_agent new_item.id) (get_agent other.id) < 0)) then

                    Effect.perform ( Early_return  idx)
                  else(
                       loop_while (i + 1) idx
                         (if other_left = left then
                            other_right < right
                         else
                            scanning)
                  )
        )
        in
        (match loop_while left_index left_index false with
        | effect Early_return idx, _k ->
          if idx = List.length doc.doc_content then
           doc.doc_content @ [new_item]
          else
           List.concat (
               List.mapi (fun i x ->
                 (* Printf.printf "%s %s\n" x.content new_item.content; *)

                 if i = idx then [new_item; x] else [x]
               ) doc.doc_content
             )
        | _ -> let _ = log_m "All are handled by effects" in ();
               doc.doc_content
       )

    (* Local insert before mergine with local document *)
    let insert doc agent pos text =
    let version =  check_version doc agent in
    let item = {
         content = text;
         id = { agent = Some agent ; seq = Some version };
         origin_left = get_left_or_right_elt doc  (pos - 2);
         origin_right = get_left_or_right_elt doc (pos - 1);
         deleted = false
       } in
    let updated_content = merge doc item in

   let updated_version = VersionMap.add agent version doc.version  in
   let updated_doc =
      {
        doc_content = updated_content;
        version = updated_version
      } in
   doc_content_store :=  updated_doc ;       (* Local store for replica *)
   updated_doc
    end

end

module CRDTOp = Crdt
