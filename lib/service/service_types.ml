

module  CapIdEntry = struct
  type t = int
  let compare x x1 =
    Int.compare x x1
end

module EntryMap = CCMap.Make(CapIdEntry)
type url_map = string EntryMap.t

let reverse v t =
  EntryMap.fold (fun k v' acc -> if (String.compare v  v' = 0) then Some k else acc) t None

let get_url cap_file =
  try
    let ch = open_in cap_file in
    let uri_str = input_line ch in
    close_in ch;
    `Ok (Uri.of_string uri_str)
  with
  | Sys_error msg -> `Error ("File error: " ^ msg)
  | End_of_file -> `Error "File is empty"
(* This is  temporary logic to connect to the only other replica. *)
(* If '0.cap'  is the current 'cap' file, connect using '1.cap' which *)
(* is the other replica's file . The number '0' or '1' is passed using *)
(* Cmdliner *)
let get_replica_cap_file cap_file_id  =
  match cap_file_id  with
  | x when x = 0 ->
      "/Users/anu/Documents/rays/collaborative-editor/lib/mergedoc/"
      ^ ( Int.to_string 1 ) ^ ".cap"
  | x when x = 1 ->
      "/Users/anu/Documents/rays/collaborative-editor/lib/mergedoc/"
      ^ ( Int.to_string 0 ) ^ ".cap"
  | _  -> failwith "Incorrectly configured cap file path"
