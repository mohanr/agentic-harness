(* This GDT is for educational purposes *)
(* and does not use type indexing  *)
type choice_point = {
  fallback : doc option;
  nesting_level : int;
  linebuffer_count : int;
  linetext_length : int;
  flatten : bool;
  can_backtrack : bool;
  mutable resume_at : int;
}

and doc =
  | Empty : doc
  | Line : doc
  | Text : string -> doc
  | Append : doc * doc -> doc
  | Nest : int * doc -> doc
  | Flatten : doc -> doc
  | Choice : doc * doc -> doc
  | Alternative : doc * doc -> doc

and item =
  | Empty_Item : item
  | Doc : doc -> item
  | SetNesting : int -> item
  | EndFlatten : item
  | ChoicePoint : choice_point -> item
