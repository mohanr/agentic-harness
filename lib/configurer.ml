open Configurer_intf
open Service_types


let get_server_urlmap  (m : (module  Node )) =
  let module M = (val m : Node ) in
  M.cap_id_map

let get_env  (m : (module  Node )) =
  let module M = (val m : Node ) in
  M.env

module Make(N:Node)  = struct

  include MakeConfigurer

  let set_size width height = { width; height }

  type node_config = {
    other_nodes : string EntryMap.t;
    env : Eio_unix.Stdenv.base;
  }
  (* Reused code doesn't need some features *)
  let set_config () =
    {
      other_nodes = get_server_urlmap (module N);
      env = get_env (module N);
    }

 end
