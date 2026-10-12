open Types
open Terminal

module Window = struct

module Border = Set.Make(struct
  type t = string
  let compare a b = compare (String.lowercase_ascii a) (String.lowercase_ascii b)
end)

let get_plain_style () = {

  left_middle = "├";
  cross_middle = "┼";
  right_left      = "┤";
  top_middle = "┬";
  bottom_middle = "┴";
  top_left      = "┌";
  top_right     = "┐";
  bottom_left   = "└";
  bottom_right  = "┘";
  vertical_left  = "│";
  vertical_right = "│";
  horizontal_top    = "─";
  horizontal_bottom = "─";
  half_left =    "▌";
  half_right=       "▐";
  top_left_ascii     =  "|";
  top_right_ascii     =  "|";
  bottom_left_ascii   =    "|";
  bottom_right_ascii  =     "|";

}

(* (set-fontset-font t '(#x2580 . #x259F) (face-attribute 'default :family)) *)

let default_window_style() =
  let plain_style = get_plain_style() in
  let init_border_style = Border.empty |>
     Border.add plain_style.top_left|>
     Border.add plain_style.top_right|>
     Border.add plain_style.bottom_left|>
     Border.add plain_style.bottom_right|>
     Border.add plain_style.vertical_left|>
     Border.add plain_style.vertical_right|>
     Border.add plain_style.horizontal_top|>
     Border.add plain_style.horizontal_bottom
    in init_border_style

let set_title title =

  let code = Terminal.ansi_escape_codes() in
  code.set_window_title1 ^ title  ^ code.set_window_title2

end
