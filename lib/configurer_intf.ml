open Service_types

module MakeConfigurer = struct


type config = {
  width : int;
  height : int;
}

end

module type Configurer=
sig

  include module type of MakeConfigurer
  val set_size : int -> int -> config

end


module type Node = sig
    val cap_id_map : string EntryMap.t
    val env : Eio_unix.Stdenv.base

end
module type MAKER = Configurer

module type Intf = sig
  module Make(_:Node) : MAKER

end
