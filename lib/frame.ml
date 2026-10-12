open Types
open Tui_types

(* Frame is not properly used now *)
module Frame = struct
let default_area ()= Area.get_area()

  let get_frame() =
    (* Create frame  *)
    {
      cursor_position = Some ({x = 0; y = 0});

      viewport_area = Area.get_area()
    }


end
