open Layout_types
open Core
open Stdlib
open Effect
open Effect.Deep
type _ Effect.t += Cannot_Backtrack : unit -> unit Effect.t

module type PARAMS = sig
  val page_width :int
end


module Docu(Params : PARAMS) = struct

     let page_width = Params.page_width

     let flatten = ref true

     let nesting_level = ref 0

     let wrote_indentation = ref 0

     let linetext_length = ref 0

     let linebuffer_count = ref 0

     let doc_stack : item Stack.t = Stack.create()

     let line_buffer  = ref List.([])

     let can_backtrack  = ref true

     let output_buffer =  Buffer.create 256

     (* TODO  *)
    let layout_printf fmt =
       let b = Buffer.create 256 in (*  Should be configurable*)
       let ppf = Format.formatter_of_buffer b in
       Format.kfprintf (fun ppf ->
          Format.pp_print_flush ppf ();
          Buffer.contents b
       ) ppf fmt

    let push item = Stack.push item doc_stack

    let pop item =

        if Stack.length doc_stack = 0 then
            None
        else
            let item = Stack.pop doc_stack in
            Some item



    let write text =
        List.append !line_buffer [text]


    let fits() = (!wrote_indentation + !linetext_length) <= page_width



   let peek stack i  =
     let l =
       Stack.to_seq stack
       |> List.of_seq
     in
       List.nth l i

    let rec commit ()=
      (* let rec drop n l = *)
      (*     if n == 0 then l *)
      (*     else (drop (n -1) (match l with a::b -> b)) *)
      let replace_in_list l idx  =
      let local_l = Stack.to_seq l
      |> List.of_seq in
      let local_s =
       List.concat (
           List.mapi (fun i x ->
                 if i = idx then [Empty_Item; x] else [x]
           ) local_l
         )
       |>
       List.to_seq |>
       Stack.of_seq
      in local_s
      in
      let _ =
      let rec loop_while stack i =
        if i >= 0 then(
          match peek stack i with
          | ChoicePoint cp ->
           let rec loop_while_choice_point (stack : item Stack.t) j =
            if j <= i then
             loop_while_choice_point  (replace_in_list doc_stack j)  (*  TODO Stop repeating this*)
                ( j + 1 )
            else
             loop_while doc_stack cp.resume_at
           in
           loop_while_choice_point doc_stack (cp.resume_at + 1);
          |_ ->
           loop_while stack (i - 1)
        )
        else(
           loop_while stack (i - 1)
        )
        in
        loop_while doc_stack (Stack.length doc_stack) in
        can_backtrack  := false


    let flushes endofdoc  =
        (if not endofdoc then
          commit()
        else begin
            let rec loop_while content =
            match content with
              | hd :: tl -> let () = Buffer.add_string output_buffer hd in
                             loop_while  tl
              | [] -> ()
            in loop_while !line_buffer
          end);
        line_buffer := []



(* type _ eff += Foo : (unit -> 'a) eff *)

(* let f () = perform Foo () *)

(* let res : type a. a = *)
(*   match f () with *)
(*   | x -> x *)
(*   | effect Foo, k -> *)
(*      continue k (fun () -> perform Foo ()) *)

    let backtrack()   =
       let module M =
       struct type _ Effect.t += Next : item -> (unit -> unit) Effect.t end in
       let open M in
       let f () =  perform (Next (Stack.pop doc_stack)) () in
        try
             if not !can_backtrack then
              perform (Cannot_Backtrack ())
             else(
              let res  =
                (match f () with
                    | x -> x
                    | effect Next v, k ->
                     (match v with
                     | ChoicePoint cp ->
                           let () = (match cp.fallback with | Some v -> push (Doc v )| None -> ()) in
                           nesting_level := cp.nesting_level ;
                           line_buffer := List.filteri( fun  i a ->
                                                       i >= cp.linebuffer_count &&
                                                       i <= (List.length !line_buffer)
                                                        - cp.linebuffer_count) !line_buffer;
                           linetext_length := cp.linetext_length ;
                           flatten :=  cp.flatten;
                           can_backtrack :=  cp.can_backtrack;
                     | _ ->
                       if Stack.length doc_stack = 0 then
                         ()
                       else
                          continue k f
                     )
                )
                in res
              )

         with
          | effect Cannot_Backtrack v, k -> ()

    let backtrack_check() =
        if (!can_backtrack && not (fits ())) then
            backtrack()
        else ()

    let write content =
      line_buffer := List.append !line_buffer [content]

    let get_resume_at candidate =
      let chosen_candidate =
      let rec loop_while c =
        (match c with
        | c when c >= 0 ->
                                  let local_l = Stack.to_seq doc_stack
                                  |> List.of_seq in
                                   (match List.nth local_l c  with
                                   |  ChoicePoint  cp ->
                                        loop_while cp.resume_at
                                   |  _ -> loop_while c
                                   )
        | _ ->   candidate
        )
      in loop_while candidate
      in chosen_candidate


    let createchoicepoint
        fallback resume_at
    =
        {
            fallback = fallback;
            nesting_level = !nesting_level;
            linebuffer_count = !linebuffer_count ;
            linetext_length = !linetext_length ;
            flatten = !flatten;
            can_backtrack = !can_backtrack ;
            resume_at = resume_at
        }



    let rec execute() =
       try
        let rec loop_while item =
         Format.printf "%a\n" Sexp.pp_hum ([%sexp_of: item] item );
          match item with
          (* | `Empty -> failwith "Nothing in the stack" *)

          | Doc Empty |  Empty_Item ->
                  backtrack_check ();
                  loop_while (Stack.pop doc_stack)
          | Doc Line->
                    if (not !can_backtrack && (!flatten || not (fits())))
                    then
                      backtrack()
                    else
                        let () = write "\n" in
                        flushes false;
                        linetext_length := 0;
                        if (!nesting_level  > 0) then
                        let () = write
                          (String.make !nesting_level ' ' ) in
                        wrote_indentation := !nesting_level ;
                        loop_while (Stack.pop doc_stack)
          | Doc Text text ->
                     let () = write text in
                     linetext_length := (!linetext_length + (String.length text));
                     backtrack();
                     loop_while (Stack.pop doc_stack)

          | Doc Append (left, right) ->

                    push (Doc right);
                    push (Doc left);
                     loop_while (Stack.pop doc_stack)
          |Doc Nest (n, child) ->
                    push (SetNesting !nesting_level );
                    nesting_level := !nesting_level + n;
                    push (Doc child);
                     loop_while (Stack.pop doc_stack)
          |Doc Alternative ( default, flattened )->
                    push (Doc (if !flatten then flattened else default));
                     loop_while (Stack.pop doc_stack)
          |Doc Flatten child ->
                    if !flatten then
                        flatten := true;
                        push EndFlatten;
                    push (Doc child);
                     loop_while (Stack.pop doc_stack)
          |Doc Choice (first, second) ->
                    push (ChoicePoint (createchoicepoint (Some second) ((Stack.length doc_stack) - 1)));
                    can_backtrack := true;
                    push (Doc first);
                     loop_while (Stack.pop doc_stack)
          |ChoicePoint cp ->
                    let resume_at = get_resume_at cp.resume_at in
                    if resume_at < 0
                      then ()
                    else
                    let resume =
                         Stack.to_seq doc_stack
                        |> List.of_seq in
                    let v = List.nth resume cp.resume_at in
                    cp.resume_at <- resume_at - 1;
                    push ( ChoicePoint cp);
                    push v;
                     loop_while (Stack.pop doc_stack)
          | SetNesting level->
                    nesting_level := level;
                     loop_while (Stack.pop doc_stack)
          | EndFlatten->
                    flatten := false;
                     loop_while (Stack.pop doc_stack)
        in loop_while (Stack.pop doc_stack)
       with Stack.Empty -> ()


    let layout document =
        let () = push document in
        let () = execute() in
        let () = flushes true in
        let contents = Buffer.contents output_buffer in
        contents

    let render document =
    layout document
end

module I_Params= struct
  let page_width = 10           (* Example  *)
end

module Layout = Docu( I_Params)
