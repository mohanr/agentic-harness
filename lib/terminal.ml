open Term_driver
open Types
open Logger.Logger


module type terminal_operations  = sig
    val draw : unit -> unit
    val ansi_escape_codes : unit -> ansi_escape_codes
    val get_out_channel: unit -> Unix.file_descr
    val get_in_channel: unit -> in_channel
    val change_mode : unit -> Unix.terminal_io

  module Cursor : sig
    val hide_cursor  : unit -> string
    val set_cursor_position : location ref -> string
    val set_cursor_new_position : location  -> unit
    val set_cursor_blinking : unit -> unit
  end
end

module Terminal                 (* consider adding a state monad *)
  : terminal_operations  = struct

let change_mode ()=
     let enable_raw_mode () =
       let stdin_fd = Unix.descr_of_in_channel stdin in
       let termios = Unix.tcgetattr stdin_fd in
       let new_termios =
         Unix.
           { termios with c_icanon = false; c_echo = false;
                          c_vmin = 1; c_vtime = 0 ; c_opost =false }
       in
       Unix.tcsetattr stdin_fd Unix.TCSAFLUSH new_termios;
       termios
    in enable_raw_mode()


let get_out_channel() =
   let stdout_fd  = Unix.descr_of_out_channel stdout in
   if Unix.isatty Unix.stdin then
     let _ = log_m "Warning: getting stdin, which is a tty." in
     stdout_fd
   else
     let _ = log_m  "Error: getting stdin, which is a tty." in
     failwith "Error: getting stdin, which is a tty."

let get_in_channel() =
   (* let stdin_fd = Unix.descr_of_in_channel stdin in *)

   if Unix.isatty Unix.stdin then
     let _ = log_m  "Warning: getting stdin, which is a tty." in
     stdin
   else
     let _ = log_m  "Error: getting stdin, which is a tty." in
     failwith "Error: getting stdin, which is a tty."

let enter_alt_screen () =
  let fd =get_out_channel () in
  ignore (Unix.write_substring fd "\x1b[?1049h" 0 8)

let leave_alt_screen () =
  let fd =get_out_channel () in
  ignore (Unix.write_substring fd "\x1b[?1049l" 0 8)



let draw() = ()

(*  TODO What is a mock driver ? *)
type terminal = {
    driver : MockDriver.t;
}

let ansi_escape_codes() = {
  text_cursor_enable = "\x1b[?25h";
  reset_text_cursor_enable = "\x1b[?25l";
  set_window_title1 = "\x1b]2;";
  set_window_title2 =  "\x07";
  text_cursor_enable_blinking = "\x1b[?12h\x1b[1 q"
}
(* https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences *)

module Cursor = struct

    let location = ref {x = 0 ; y = 0 }

    let code = ansi_escape_codes()

    let hide_cursor ()=
       code.reset_text_cursor_enable

    let show_cursor ()=
       code.text_cursor_enable

    let get_cursor_location () =
        !location

    let reset_text_cursor_enable() =
       code.reset_text_cursor_enable

    let set_cursor_position location=
        Printf.sprintf  "\x1b[%d;%dH" !location.x !location.y

    let set_cursor_new_position location=
        let fd = Unix.descr_of_out_channel stdout in
        let out =  Printf.sprintf  "\x1b[%d;%dH" location.x location.y in
        ignore (Unix.write_substring fd out
                0 (String.length out))

    let set_cursor_color  =
        Printf.sprintf "\x1b]12;#00FFFF\007"

    let set_cursor_blinking() =
        let fd = Unix.descr_of_out_channel stdout in
        let out = code.text_cursor_enable in
        ignore (Unix.write_substring fd out
                0 (String.length out));
        let out = code.text_cursor_enable_blinking in
        ignore (Unix.write_substring fd out
                0 (String.length out));
        let out = set_cursor_color in
        ignore (Unix.write_substring fd out
                0 (String.length out));





end
end
