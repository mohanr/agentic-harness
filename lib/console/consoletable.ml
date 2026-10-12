open Re

(* https://homepages.inf.ed.ac.uk/wadler/papers/prettier/prettier.pdf *)
(* This is an OCaml port of part of a Typescript library - *)
(*  https://github.com/console-table-printer/console-table-printer. I needed a way *)
(* to format my printed values. The research paper mentioned above is combined *)
(* with this to code a small utility *)

module ConsoleTable = struct

type cell =
      Int_data of Base.int Base.Option.t
    | String_data of Base.string Base.Option.t
    | Bool_data of Base.bool
[@@deriving compare, sexp]

let cell_text = function
  | Int_data (Some i) -> string_of_int i
  | Int_data None -> String.empty
  | String_data (Some s) -> s
  | String_data None -> String.empty
  | Bool_data b -> string_of_bool b

let get_field row name =
  match List.assoc_opt name row with
  | Some c -> cell_text c
  | None -> String.empty

type row = { row_data : string; cell_data : cell }
type alignment = Left of string | Center of string | Right of string

let horizontal = "─"
let vertical = "│"


let regex_split text width : string list=
(* FIXED: Explicitly creates group 1 (newline) and group 2 (line text) *)
let regex = Re.compile Re.(seq [
  opt (group (alt [str "\r\n"; str "\n"; str "\r"])); (* Group 1 *)
  group (rep (compl [char '\n'; char '\r']))          (* Group 2 *)
]) in
 let regex1 = Re.compile Re.(seq [rep space; rep1 ( compl [space])]) in
  let rec loop_while_newline pos acc1 =
   ( match Re.exec_opt ~pos regex text with
       |Some group ->
              let line_text = Re.Group.get group 2 in
               let next_line_pos = Re.Group.stop group 0 in
               let rec loop_while_word pos current current_width acc2 =
                 match Re.exec_opt ~pos regex1 line_text with
                   |Some group ->
                          let word = String.trim (Re.Group.get group 0) in
                          let next_pos = Re.Group.stop group 0 in
                          let wl = String.length word  in
                          if (current_width + wl) <= width then
                            let new_current = current @ [word] in
                            let current_width = current_width +  wl + 1 in
                            loop_while_word next_pos  new_current current_width acc2
                          else
                           let acc2 =
                            if List.length  current > 0 then
                               acc2 @ [String.concat  " " current]
                            else
                               acc2 in
                            let new_current = [word] in
                            let current_width = wl + 1 in
                            loop_while_word next_pos  new_current current_width acc2

                   | None -> (* Accumulator *)
              if List.length current > 0 then
                acc2 @ [String.concat " " current]
              else acc2

          in let current_acc2 = loop_while_word 0 [] 0 [] in
          let acc1 = acc1 @ current_acc2 in
        if next_line_pos <= pos || next_line_pos >= String.length text then acc1
        else loop_while_newline next_line_pos acc1
       | None -> acc1
     )
     in loop_while_newline 0 []

let rec repeat s n =
    if n = 0 then "" else s ^ repeat s (n - 1)

let align text width alignment =
  let remaining = width - (String.length text) in
  match alignment with
  |  "left" ->
    text ^ (repeat String.empty remaining)
  |  "center" ->
    let left = floor (Int.to_float (Int.div remaining  2)) in
    (repeat String.empty (Float.to_int left)) ^
         text ^ (repeat String.empty  (remaining - (Float.to_int left)))
  |  _ ->
  (repeat String.empty  remaining) ^ text

let border  left middle right widths =
  left ^ ((List.map (fun width ->
                    repeat horizontal (width + 2)) widths) |>
     String.concat middle) ^ right ^ "\n"

let render_table  rows  alignment  =
  let open Window in
  let style = Window.get_plain_style() in
  let columns =
  let rec loop_while_rows row columns=
    match row with
    | { row_data = rd ; cell_data = cd } :: tl ->
                              let col = (match (List.find_opt (fun v -> v = rd)
                                                          columns)  with
                                  | Some found -> columns
                                  | None -> columns @ [rd]
                               ) in
                              let col1 = (match (List.find_opt
                                                  (fun v -> v = cell_text cd)
                                                          col)  with
                                  | Some found -> col
                                  | None -> col @ [cell_text cd]
                               ) in

                               loop_while_rows tl col1
    |[] -> columns

  in loop_while_rows rows []
  in
  let max_column_width (rows: row list)  =
    Printf.printf "Columns %d\n" (List.length columns);
    List.mapi(fun index name ->
    List.fold_left max 0
             (List.fold_left
                  (fun acc row ->
                    if index = 0 then
                    match row with
                     | { row_data = rd ; _ }  ->
                               acc @  [String.length (cell_text (String_data
                                                                   (Some rd)))]
                   else
                   match row with
                     | { row_data = rd ; cell_data = cd }  ->
                               acc @  [String.length (cell_text  cd)]
                   ) [] rows )
    ) columns
  in
  let render columns row  is_header =
    let cells  =
    List.mapi (fun index name ->
          regex_split ( if is_header then
                           name
                         else
                           match index with
                            | 0 -> cell_text (String_data (Some row.row_data))
                            | 1 -> cell_text  row.cell_data
                            | _ -> failwith "Wrong index"

                        )
                        (List.nth
                        (max_column_width rows )
                         index)
                       ) columns in
    (* List.iter ( fun v -> *)
    (*    let open Sexplib in *)
    (*     Format.printf "Content %a\n" Sexp.pp_hum ([%sexp_of: Base.string Base.list] v )) *)
    (*   cells; *)
    (*Return the maximum of integer values  *)
    let height() =
    List.fold_left  (fun acc v ->
                          max acc (List.length v)) 0 cells in
    let rendered_area =
       let rec loop_while_render render_area line height=
           Printf.printf "Widths %d\n" (List.length (max_column_width rows));
           if line < height then (
                let contents =
                  List.mapi (fun index cell ->
                    align
                      (if line < List.length cell then
                         List.nth cell line
                       else
                         String.empty)
                      (List.nth (max_column_width rows) index)
                      (if is_header then "center" else alignment)
                  ) cells
               in
               loop_while_render
                ( render_area @ [ style.vertical_left ^
                                ( String.concat " " contents ) ^
                                  style.vertical_left ]
                )
                (line + 1)
                height
           )
           else render_area
        in
        loop_while_render [] 0 (height())
     in rendered_area
  in
  let render_row rows columns =
       let b = Stdlib.Buffer.create 2096  (*  Should be configurable*)
           in
           List.iter (
               fun row ->
               Stdlib.Buffer.add_string b
                           (border "┌" "┬" "┐" (max_column_width rows ));
                Stdlib.Buffer.add_string b
                           (String.concat String.empty
                              (render columns row false)); ) rows;
         Stdlib.Buffer.contents b in
         render_row rows columns

end
