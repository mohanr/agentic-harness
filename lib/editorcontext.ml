open Tui_types
open Textholder
open Terminal.Terminal.Cursor
open Editorstate
open Logger.Logger
open Buffer
open Configurer
open Types
module  W  =Widget
module C = Make
module A = Area
module B = Buffer(A)

type _ Effect.t += Set_cursor_blinking :  tui_editor_view   ->
                                          tui_editor_view   Effect.t
module EditorContext
                    ( EditorState : EState  ) = struct

      let cursor_after_text text =
        { x = 6; y = 11 + String.length text }

      (* Initial state in the state machine *)
      let init_state text =
        let effectful_init_state () =
           let string_text =
             Textholder.Text {
               self = text ;
               text_length = String.length;
             } in

           Effect.perform (Set_cursor_blinking
                   {
                       cursor_position = Some (cursor_after_text text);
                       buf =  Stdlib.Buffer.create 256;
                       holder =  Textholder.make string_text ;
                   }) in
        let state_to_persist =
        (match effectful_init_state ()  with
        | effect Set_cursor_blinking v, k ->
                                let () =
                                (match v.cursor_position with
                                | Some l -> set_cursor_new_position {x=l.x;y=l.y}
                                | None -> ()
                                ) in
                                (* let _ = log_m "Set cursor blinking" in *)
                                let () = set_cursor_blinking() in
                                v
        | state-> state
       )in
        EditorState.set {next = state_to_persist};

        state_to_persist

let load_buffer text = (* State is stored.State passing *)
                       (* style should be explored. *)
           let string_text =
             Textholder.Text {
               self = text ;
               text_length = String.length;
             } in
            let b = Stdlib.Buffer.create 256 in
            let () = Stdlib.Buffer.add_string b text
            in
            let _ = log_m "Editor context Buffer contents [%s]"
                (Stdlib.Buffer.contents b) in
            let var =
            {
                cursor_position = Some (cursor_after_text text);
                buf =  b ;
                holder =  Textholder.make string_text ;
            } in
           EditorState.run ( EditorState.load_buffer var )

end
