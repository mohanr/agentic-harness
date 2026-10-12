open Core
open Types
open Crdt.CRDTOp.Crdt_buffer
open Layout_configurer_intf

let create_config_node () : (module Configurer)=

  let module Config = struct

   include MakeConfigurer
   (* Default ? *)
   let config = {

    fallback = false;
    nesting_level = 0;
    linebuffer_count = 0;
    linetext_length = 0;
    flatten = false;
    can_backtrack = false;
    resume_at = 0;
   }



  end in
  (module Config: Configurer )

(* Demonstration of how effects could be used. *)
(* But simpler primitives instead of effects are recommended *)
let%expect_test "Insert one character"=
    let new_doc = make() in
    let pos = 1 in
    let merged_content = insert
                       new_doc
                       "Text"
                       pos
                       "a"
                       in
    (* let rec loop_while  l = *)
    (* (match l  with *)
    (*         | hd :: tl-> (\* Printf.printf "%s" hd.content; *\) *)
    (*                      loop_while tl *)
    (*         |[] -> ()) *)
    (* in loop_while  merged_content; *)
    List.iter merged_content.doc_content ~f:(fun v ->
        Format.printf "%a" Sexp.pp_hum ([%sexp_of: item] v )) ;
    [%expect {|
      ((content a) (id ((agent (Text)) (seq (0)))) (origin_left ())
       (origin_right ()) (deleted false))
      |}]

let insert  new_doc  pos c =
     insert new_doc "Text" pos c

let text_of doc =
  List.map doc.doc_content ~f:(fun item -> item.content)
  |> String.concat ~sep:""



let%expect_test "Merge two documents"=
    let new_doc = make() in
    let new_doc = insert new_doc 1 "a" in
    let new_doc1 = make() in
    let open Document.Document in

    let new_doc1 = merge_both new_doc new_doc1 in

    List.iter new_doc1.doc_content ~f:(fun v ->
        Format.printf "%a" Sexp.pp_hum ([%sexp_of: item] v )) ;
    [%expect {|
      ((content a) (id ((agent (Text)) (seq (0)))) (origin_left ())
       (origin_right ()) (deleted false))
      |}];
      let merged_content = insert new_doc 2 "b" in
      let merged_content = insert merged_content 1 "c" in
      let merged_doc = merge_both merged_content new_doc1 in
      let merged_text =
        List.map merged_doc.doc_content ~f:(fun item -> item.content)
        |> String.concat ~sep:" "
      in
      List.iter merged_doc.doc_content ~f:(fun v ->
        Format.printf "%a\n" Sexp.pp_hum ([%sexp_of: item] v ))
        ;
      assert (String.equal merged_text "c a b");
      Format.printf "\n%s" merged_text;
      [%expect {|
        ((content c) (id ((agent (Text)) (seq (2)))) (origin_left ())
         (origin_right (((agent (Text)) (seq (0))))) (deleted false))
        ((content a)
                                                                       (id
                                                                        ((agent
                                                                          (Text))
                                                                         (seq (0))))
                                                                       (origin_left
                                                                        ())
                                                                       (origin_right
                                                                        ())
                                                                       (deleted
                                                                        false))

        ((content b) (id ((agent (Text)) (seq (1))))
         (origin_left (((agent (Text)) (seq (0))))) (origin_right ())
         (deleted false))

        c a b
        |}];
        VersionMap.iter (fun k v ->
        Format.printf "%a %a\n" Sexp.pp_hum ([%sexp_of: string] k )
           Sexp.pp_hum ([%sexp_of: int] v )) merged_doc.version;
        (* print_s [%sexp (some_map : int Int.Map.t)] *)

  [%expect {| Text 2 |}]

let%expect_test "Test console"=
  let open Consoletable.ConsoleTable in
  let rows = [] in
  let  rows = rows @ [{ row_data = "OpenAI";
                        cell_data = String_data (Some "Navier Stokes")}] in
  Printf.printf "%s\n" (render_table  rows  "centre");
  [%expect {|
    Columns 2
    Columns 2
    Columns 2
    Columns 2
    Widths 2
    Columns 2
    Columns 2
    Columns 2
    Widths 2
    ┌────────┬───────────────┐
    │OpenAI Navier Stokes│
    |}]
