open Types
open Configurer
open Buffer
open Textholder


 type key = [ | `ASCII of char ]
  (*  Viewport etc.*)
type frame = {
    cursor_position: location Option.t;

    viewport_area:Area.t;

}
type tui_editor_view = {
    cursor_position: location Option.t;
    buf : Stdlib.Buffer.t;
    holder : Textholder.textholder;
}

type state = { next : tui_editor_view }

type 'a t = state -> 'a * state
