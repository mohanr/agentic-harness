open Eio.Std
open Widget
open Event_stream
open Logger.Logger
open Editorstate
open Editorcontext
open Tui_types

module type TUIHandler = sig
  val periodic_timer : Eio_unix.Stdenv.base -> unit
end

module Ed : sig
    val init_state : string -> tui_editor_view
  end = EditorContext (EditorState)
module TUIOperator = struct

let unpaused = ref (Promise.create_resolved ())

let get_flow_buffer flow ~max_size  =
   Eio.Buf_read.of_flow flow ~max_size
(* https://github.com/ocaml-community/lambda-term/blob/master/src/lTerm.ml *)
let parse p buf =
  Eio.Buf_read.format_errors p buf (* No EOF marker is required *)
                                      (* and each character is read *)

let message =
        let msg = Eio.Buf_read.uint8 in
         msg

let get_eio_stdin env =
 Eio.Stdenv.stdin env

let read_eio_stdin buf stream =
     match parse message buf  with
      | Ok  msg  -> let _ = log_m "%d " msg in Eio.Stream.add stream (`ASCII (Char.chr msg) :> key )
      | Error (`Msg err) -> Eio.traceln "Parse failed: %s" err

let receive_event flow sw =
    let stream = EventStream.get_event_stream() in
    let buf = get_flow_buffer flow ~max_size:1024 in
    let open Stdlib in
       Fiber.fork ~sw
         (fun () ->

             let rec loop_while_event () =

               try
                 read_eio_stdin buf stream;
                 Fiber.yield ();
                 loop_while_event ();
               with End_of_file -> ()
                  | Eio.Cancel.Cancelled _ as exn -> raise exn
                  | exn -> let _ = log_m "%s" (Printexc.to_string exn) in ()
             in
             loop_while_event ()
         )


let run env =
   let _ = log_m "periodic timer " in
   Eio.Switch.run @@ fun sw ->
   let clock = Eio.Stdenv.clock env in

   Renderer.render();
   EventStream.handle_event env sw;

   let _view = Ed.init_state "" in
   (* EventStream.handle_event sw; *)

   let eio_stdin = get_eio_stdin env in
   receive_event eio_stdin sw;
   try
     while true do
        Promise.await !unpaused;
        Eio.Time.sleep clock 3.5;
        flush stdout;
        (* let _ = log_m "Timer ticks" in *)
        (* () *)
     done
   with
     | Eio.Cancel.Cancelled _ as exn ->
          let _ = log_m "Timer ticks stop (Lwt)" in
          raise exn
     | Lwt.Canceled ->
          let _ = log_m "Timer ticks stop (Lwt)" in
          raise Lwt.Canceled
     | exn -> let _ = log_m "%s" (Printexc.to_string exn) in ()

let end_loop()  =
  Printf.printf "End loop"

let periodic_timer env =
  let open Terminal in
  Switch.run  @@ fun sw ->
  let _ = Terminal.change_mode () in
  Fiber.fork ~sw ( fun () -> run env  );
  ()

end


module TUIOp = TUIOperator
