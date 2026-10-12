type _ document =
  | Empty
  | Emptydoc :  'a document
  | Text : string  ->  'a document
  | WhiteSpace : int ->  'a document
  | Line :  'a document
  | Append : 'a document * 'a document ->  'a document
  | Choice : 'a document * 'a document ->  'a document
  | Nest : int * 'a document ->  'a document
  | Flatten : 'a document ->  'a document
  | Alternative : 'a document * 'a document -> 'a document
  | SetNesting : int -> 'a document
  | EndFlatten :  'a document -> 'a document
(* [@@deriving show ] *)
