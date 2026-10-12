open Types
open Buffer
open Window
open Terminal
open Configurer
open Logger.Logger
open Editorview

module C : Configurer_intf.Configurer = struct
  include Configurer_intf.MakeConfigurer
  let set_size width height = { width; height }
end
module A = Area
module B = Buffer(A)
module BF = BufferManipulator (C) (B)


let add buf s =
  let open Stdlib in
  Buffer.add_string buf s


(* https://hal.science/hal-01503081/file/format-unraveled.pdf *)
(* Supposed to be the container widget within which other widgets render *)
module type Widget = sig
    val render : Area.t  -> ?custom_formatter:Format.formatter -> t -> unit
end

let plain_style = Window.get_plain_style ()

let draw_hborder_in_buffer (border : style ) width bottom_or_top =
  let open Stdlib in
  let rec repeat ?(n = 0) s =
      if n = 0 then "" else s ^ repeat s ~n:(n - 1)
  in
  let draw b buffer =
    match b with
    | HoBorder s ->
                   if bottom_or_top then
                    Buffer.add_string  buffer  plain_style.top_left
                   else
                    Buffer.add_string  buffer  plain_style.bottom_left;
                    Buffer.add_string  buffer (repeat ~n:(width - 2)
                                                  s ) ;
                   if bottom_or_top then
                    Buffer.add_string  buffer  plain_style.top_right
                   else
                    Buffer.add_string  buffer  plain_style.bottom_right;
                    buffer
    |  _-> buffer
  in
     draw border (Buffer.create (width + 2))

let draw_vborder_in_buffer border width =
  let open Stdlib in
  let draw b buffer =
    match b with
    | VeBorder s ->  let l = width in
        Buffer.add_string buffer s;
        (* Buffer.add_string buffer "\x1b[0;38;5;12m"; *)

        (* Buffer.add_string buffer plain_style.half_right; *)
        Buffer.add_string buffer "\x1b[0;38;5;15;48;5;12m";
        Buffer.add_string  buffer (String.make (l - 2) ' ');
        Buffer.add_string buffer  "\x1b[0m";
        Buffer.add_string buffer "\x1b[48;5;12m";

        (* Buffer.add_string buffer "\x1b[0;38;5;12m"; *)

        (* Buffer.add_string buffer plain_style.half_left; *)

        Buffer.add_string buffer "\x1b[0m";
        Buffer.add_string buffer s;
         buffer
    |  _-> buffer
  in
   try
     draw border (Buffer.create width)
      with e ->
       let msg = Printexc.to_string e
       and stack = Printexc.get_backtrace () in
         Printf.eprintf "there was an error: %s%s\n" msg stack;
         raise e


(* https://ocaml.org/manual/5.0/api/Format_tutorial.html#1_Refinementonhovboxes *)
module Widget( EditorView : Renderable.R ) = struct
   type Format.stag += Highlight

   let tui_stag_functions (area : Types.Area.t) = {
     Format.mark_open_stag = (fun stag ->
       let plain_style = Window.get_plain_style() in (*  Default *)
       let open Stdlib in
       match stag with
       | Format.String_tag s ->
                (match s with
                | s when String.equal s "Highlight"
                        ->   "\x1b[48;5;162m\x1b[38;5;255m";
                | s when String.equal s "HBorder"
                      ->
                         let buf = draw_hborder_in_buffer (HoBorder  plain_style.horizontal_top)
                         area.width true
                          in   (Buffer.contents buf);
                | s when String.equal s "VBorder"
                      ->
                         let buf = draw_vborder_in_buffer (VeBorder  plain_style.vertical_left)
                         area.width
                          in   (Buffer.contents buf);
                | _ -> String.empty)
       | _ -> String.empty
     );
     Format.mark_close_stag = (fun _ ->  "\x1b[0m");
     Format.print_open_stag = (fun _ -> ());
     Format.print_close_stag = (fun _ -> ());
   }

   let pp_linebreak ppf () = Format.pp_print_break ppf Format.pp_infinity 0


(* https://pkg.go.dev/github.com/charmbracelet/x/ansi *)
let render_container(area : Types.Area.t) buf =
  let open Stdlib in
  let ansi_escape_codes = Terminal.ansi_escape_codes () in
  let new_location = ref { x =  0; y = 0} in
  add buf (Terminal.Cursor.set_cursor_position new_location);
  add buf "\x1b[?2026h";
  add buf ansi_escape_codes.reset_text_cursor_enable;
  add buf (Buffer.contents (draw_hborder_in_buffer (HoBorder plain_style.horizontal_top) area.width true));

    let rec loop i h =
      if i < h then
      let new_location = ref { x = i ; y = 1} in
      Buffer.add_string buf (Terminal.Cursor.set_cursor_position new_location);
      Buffer.add_string buf (Buffer.contents (draw_vborder_in_buffer
                                      (VeBorder plain_style.vertical_left) area.width));
      loop (i + 1) h
      else ()
    in
    loop 2 area.height;

  let new_location = ref { x = area.height; y = 0} in
  add buf (Terminal.Cursor.set_cursor_position new_location);
  add buf (Buffer.contents (draw_hborder_in_buffer (HoBorder plain_style.horizontal_bottom) area.width false));
  add buf "\x1b[?2026l";
  (* let out = Buffer.contents buf in *)
  (* let fd = Unix.descr_of_out_channel stdout in *)
  (* ignore (Unix.write_substring fd out 0 (String.length out)); *)
  let title = Window.set_title "Collaborative Editor" in
  let fd = Unix.descr_of_out_channel stdout in
  let _ = Unix.write_substring fd title 0 (String.length title ) in
  buf

   let render_styled_text area =
     Format.pp_set_tags Format.std_formatter true;
     Format.pp_set_formatter_stag_functions Format.std_formatter (tui_stag_functions area);

     Format.printf "@[<v 2>@,@{<Highlight>Collaborative editor.@}@]@."

   let render area ?( custom_formatter = Format.std_formatter) container_buf =
       let open Stdlib in
       (* print_string "\x1b[43;30mHello World!\x1b[0m"; *)
       let container_buf = render_container area container_buf in
       let l = [ (module EditorView : Renderable.R) ]
       in
       let create_buffer()  =
         BF.make_buffer()
       in
       let render_view() =
         let b = create_buffer() in (* Should be configurable for a widget *)
         List.iter( fun v -> let module W = ( val v : Renderable.R ) in
         let child_area : Area.t = { x = 5; y = 10; width = 30; height = 10 } in
         let child_buf = W.render child_area b in
         Buffer.add_buffer container_buf child_buf;
            ) l
           in
            let() = render_view() in
            let out = Buffer.contents container_buf in
            let fd = Unix.descr_of_out_channel stdout in
            ignore (Unix.write_substring fd out 0 (String.length out));

end

 module E = EditorView
 module Wid = Widget(E)
module Renderer = struct

let create_buffer()  =
  BF.make_buffer()


let render() =
   match  create_buffer() with
   | {area = a; contents = buf} ->
    Wid.render a buf
end
