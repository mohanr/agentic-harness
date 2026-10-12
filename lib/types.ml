open Base
open Containers

type style =
  | VeBorder of string
  | HoBorder of string
  | Glyph of string


module type Arena =

sig
       type t = {
           (* The x coordinate of the top left corner of the `Area` *)
           x : int;
            (* The y coordinate of the top left corner of the `Rect` *)
           y : int;
            (* The width of the `Area` *)
           width : int;
            (* The height of the `Area` *)
           height : int
       }

val get_area : unit -> t
val get_x : unit -> int
val get_y :  unit ->int
val get_width :  unit ->int
val get_height : unit -> int
end

 module Area : Arena = struct
       type t = {
           (* The x coordinate of the top left corner of the `Area` *)
           x : int;
            (* The y coordinate of the top left corner of the `Rect` *)
           y : int;
            (* The width of the `Area` *)
           width : int;
            (* The height of the `Area` *)
           height : int
       }
       let t = {
           (* The x coordinate of the top left corner of the `Area` *)
           x = 5;
            (* The y coordinate of the top left corner of the `Rect` *)
           y = 5;
            (* The width of the `Area` *)
           width = 51;
            (* The height of the `Area` *)
           height = 51
       }
 let get_area()  = t
 let get_x()  = t.x
 let get_y()  = t.y
 let get_width()  = t.width
 let get_height()  = t.height
end

type t = {
        area : Area.t;

        contents : Stdlib.Buffer.t;
}

type test_driver = {
    pos: int * int
}

type plain = {
  left_middle : string;
  cross_middle:  string;
  right_left  :     string;
  top_middle : string;
  bottom_middle:  string;
  top_left: string;
  top_right: string;
  bottom_left: string;
  bottom_right: string;
  vertical_left: string;
  vertical_right: string;
  horizontal_top: string;
  horizontal_bottom: string;
  half_left:        string;
  half_right:        string;
  top_left_ascii     : string;
  top_right_ascii     : string;
  bottom_left_ascii     : string;
  bottom_right_ascii     : string;

}

type location = {

  x : int;

  y: int

}
type ansi_escape_codes = {
  text_cursor_enable: string;
  reset_text_cursor_enable: string;
  set_window_title1 : string;
  set_window_title2 :  string;
  text_cursor_enable_blinking : string;
}
type identity = {
  agent : string Base.Option.t; (* Containers inferferes *)
  seq : int Base.Option.t
}
[@@deriving sexp ,compare]

type item = {
  content : string;
  id : identity ;
  origin_left : identity Base.Option.t;
  origin_right :identity Base.Option.t;
  deleted :  bool
}
[@@deriving sexp ,compare]



module  Versionkeyvalue = struct
  type t = string
  let compare x x1 =
    String.compare x x1
end
module VersionMap = CCMap.Make(Versionkeyvalue)

type doc ={
  doc_content : item list;
  version :  int VersionMap.t                   (* CCMap  *)
}

module type CRDTOperator = sig

  module Crdt_buffer : sig
    val merge : doc -> item -> item list
    val make : unit -> doc
    val insert : doc -> string -> int ->string -> doc
    val doc_content_store : doc ref
  end
end

 let get_seq identity =
   (match identity.seq with | Some v -> v
                              | None -> failwith "Error in get_seq ")
 let get_agent identity =
   (match identity.agent with | Some v -> v
                              | None -> failwith "Error in get_agent ")
 let get_identity identity =
   (match identity with | Some v -> v
                        | None -> failwith "Error in get_identity ")
